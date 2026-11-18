import os
from pathlib import Path
import subprocess
import tempfile
import unittest

HELPER = Path(__file__).resolve().parents[1] / 'scripts/stow-with-backups'


class Backups(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo, self.home = self.root / 'repo', self.root / 'home'
        self.source = self.repo / 'sample/.config/app/settings.conf'
        self.source.parent.mkdir(parents=True)
        self.source.write_text('new')
        self.target = self.home / '.config/app/settings.conf'
        self.target.parent.mkdir(parents=True)

    def run_helper(self, *options, env=None, success=True):
        result = subprocess.run([str(HELPER), '--repo', str(self.repo), '--target', str(self.home),
                                 *options, 'sample'], cwd=self.root,
                                env={**os.environ, 'HOME': str(self.home), **(env or {})},
                                capture_output=True, text=True)
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)
        return result

    def test_existing_file_is_backed_up_and_repeat_is_idempotent(self):
        self.target.write_text('old')
        unrelated = self.target.parent / 'unrelated'
        unrelated.write_text('keep')
        self.run_helper()
        backups = list(self.target.parent.glob('settings.conf-backup-*'))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), 'old')
        self.assertEqual(self.target.resolve(), self.source)
        self.run_helper()
        self.assertEqual(list(self.target.parent.glob('settings.conf-backup-*')), backups)
        self.assertEqual(unrelated.read_text(), 'keep')

    def test_foreign_directory_symlink_is_moved_without_touching_its_target(self):
        self.target.parent.rmdir()
        outside = self.root / 'outside'
        outside.mkdir()
        (outside / 'settings.conf').write_text('external')
        self.target.parent.symlink_to(outside)
        self.run_helper()
        self.assertEqual((outside / 'settings.conf').read_text(), 'external')
        self.assertEqual(self.target.read_text(), 'new')
        self.assertTrue(next((self.home / '.config').glob('app-backup-*')).is_symlink())

    def test_wrong_link_into_the_repository_remains_backed_up(self):
        other = self.repo / 'other/.config/old-settings.conf'
        other.parent.mkdir(parents=True)
        other.write_text('keep')
        self.target.symlink_to(other)
        self.run_helper()
        backup = next(self.target.parent.glob('settings.conf-backup-*'))
        self.assertTrue(backup.is_symlink())
        self.assertEqual(backup.read_text(), 'keep')
        self.assertEqual(self.target.resolve(), self.source)

    def test_dry_run_does_not_move_or_link(self):
        self.target.write_text('old')
        self.run_helper('--dry-run')
        self.assertFalse(self.target.is_symlink())
        self.assertEqual(self.target.read_text(), 'old')
        self.assertEqual(list(self.target.parent.glob('*-backup-*')), [])

    def test_absolute_source_symlink_fails_before_any_backup(self):
        self.target.write_text('old')
        (self.source.parent / 'invalid.theme').symlink_to('/home/other-user/theme')
        result = self.run_helper(success=False)
        self.assertIn('Absolute source symlink cannot be stowed', result.stderr)
        self.assertEqual(self.target.read_text(), 'old')
        self.assertEqual(list(self.target.parent.glob('*-backup-*')), [])

    def test_absolute_source_link_is_checked_inside_existing_folded_directory(self):
        self.target.parent.rmdir()
        self.target.parent.symlink_to(self.source.parent)
        (self.source.parent / 'invalid.theme').symlink_to('/home/other-user/theme')
        result = self.run_helper(success=False)
        self.assertIn('Absolute source symlink cannot be stowed', result.stderr)
        self.assertTrue(self.target.parent.is_symlink())

    def test_stow_failure_restores_original(self):
        self.target.write_text('old')
        binary = self.root / 'bin'
        binary.mkdir()
        stub = binary / 'stow'
        stub.write_text('#!/bin/sh\nexit 1\n')
        stub.chmod(0o755)
        self.run_helper(env={'PATH': str(binary) + ':' + os.environ['PATH']}, success=False)
        self.assertFalse(self.target.is_symlink())
        self.assertEqual(self.target.read_text(), 'old')
        self.assertEqual(list(self.target.parent.glob('*-backup-*')), [])

    def test_backups_are_not_overwritten(self):
        self.target.write_text('first')
        self.run_helper()
        self.target.unlink()
        self.target.write_text('second')
        self.run_helper()
        self.assertEqual({p.read_text() for p in self.target.parent.glob('*-backup-*')}, {'first', 'second'})

    def test_shared_config_symlink_is_not_replaced(self):
        self.target.parent.rmdir()
        (self.home / '.config').rmdir()
        outside = self.root / 'outside'
        outside.mkdir()
        (self.home / '.config').symlink_to(outside)
        self.run_helper(success=False)
        self.assertTrue((self.home / '.config').is_symlink())
        self.assertEqual(list(outside.iterdir()), [])


if __name__ == '__main__':
    unittest.main()
