import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class Portability(unittest.TestCase):
    def test_btop_uses_local_xdg_paths_and_preserves_old_link(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            config, state = root / 'config', root / 'state'
            link = config / 'btop/themes/current.theme'
            link.parent.mkdir(parents=True)
            link.symlink_to('/home/other-user/theme')
            env = {**os.environ, 'XDG_CONFIG_HOME': str(config), 'XDG_STATE_HOME': str(state)}
            for _ in range(2):
                subprocess.run([str(ROOT / 'scripts/setup-btop-theme')], env=env, check=True,
                               capture_output=True)
            self.assertEqual(link.readlink(), state / 'omarchy/current/theme/btop.theme')
            backups = list(link.parent.glob('current.theme-backup-*'))
            self.assertEqual(len(backups), 1)
            self.assertEqual(backups[0].readlink(), Path('/home/other-user/theme'))

    @unittest.skipIf(os.geteuid() == 0, 'desktop setup intentionally refuses root')
    def test_setup_ignores_retired_packages_left_after_git_pull(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            scripts = root / 'scripts'
            scripts.mkdir()
            shutil.copy2(ROOT / 'scripts/setup-omarchy-customizations', scripts)
            stub = scripts / 'stow-with-backups'
            stub.write_text('#!/bin/sh\nprintf "PACKAGES: %s\\n" "$*"\n')
            stub.chmod(0o755)
            for name in ['modern', 'leenium.omarchy', 'miyamoto.sakura-rain']:
                (root / name / '.config').mkdir(parents=True)
            result = subprocess.run([str(scripts / 'setup-omarchy-customizations'), '--dry-run'],
                                    text=True, capture_output=True, check=True)
            self.assertIn('PACKAGES: --dry-run modern', result.stdout)
            self.assertNotIn('PACKAGES: --dry-run leenium', result.stdout)
            self.assertNotIn('miyamoto.sakura-rain', result.stdout)


if __name__ == '__main__':
    unittest.main()
