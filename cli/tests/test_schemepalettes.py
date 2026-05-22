from __future__ import annotations

import pytest
from pathlib import Path
from zshell.utils import schemepalettes as sp


@pytest.fixture
def tmp_schemes(tmp_path: Path) -> Path:
    schemes = tmp_path / "schemes"
    schemes.mkdir()

    gmedium = schemes / "gruvbox" / "medium"
    gmedium.mkdir(parents=True)
    (gmedium / "dark.txt").write_text("background 101415\nonBackground e0e3e4\nprimary 81d3e0\nsurface 1c2021\n")
    (gmedium / "light.txt").write_text("background fbf1c7\nonBackground 3c3836\nprimary 6b5f10\nsurface fbf1c7\n")

    ghard = schemes / "gruvbox" / "hard"
    ghard.mkdir(parents=True)
    (ghard / "dark.txt").write_text("background 0b0d0e\nprimary 81d3e0\n")

    cmocha = schemes / "catppuccin" / "mocha"
    cmocha.mkdir(parents=True)
    (cmocha / "dark.txt").write_text("background 1e1e2e\nprimary cba6f7\nsecondary 756294\nsurface 313244\n")
    (cmocha / "mauve-dark.txt").write_text("background 1e1e2e\nprimary cba6f7\nsecondary 756294\nsurface 313244\n")
    (cmocha / "green-dark.txt").write_text("background 1e1e2e\nprimary a6e3a1\nsecondary 5b8964\nsurface 313244\n")

    clatte = schemes / "catppuccin" / "latte"
    clatte.mkdir(parents=True)
    (clatte / "light.txt").write_text("background eff1f5\nprimary 8839ef\nsecondary c2b8d0\nsurface ccd0da\n")
    (clatte / "mauve-light.txt").write_text("background eff1f5\nprimary 8839ef\nsecondary c2b8d0\nsurface ccd0da\n")

    cextra = schemes / "extra" / "default"
    cextra.mkdir(parents=True)
    (cextra / "dark.txt").write_text(
        "# this is a comment\n\nbackground 000000\nprimary ffffff\n\n  # indented comment  \n  secondary cccccc\n"
    )

    return schemes


class TestParseTxt:
    def test_basic(self, tmp_schemes):
        path = tmp_schemes / "gruvbox" / "medium" / "dark.txt"
        colors = sp._parse_txt(path)
        assert colors["background"] == "#101415"
        assert colors["primary"] == "#81d3e0"
        assert colors["surface"] == "#1c2021"

    def test_adds_hash_prefix(self, tmp_schemes):
        path = tmp_schemes / "gruvbox" / "medium" / "dark.txt"
        colors = sp._parse_txt(path)
        for v in colors.values():
            assert v.startswith("#"), f"value {v!r} missing # prefix"

    def test_skips_comments_and_empty_lines(self, tmp_schemes):
        path = tmp_schemes / "extra" / "default" / "dark.txt"
        colors = sp._parse_txt(path)
        assert colors["background"] == "#000000"
        assert colors["primary"] == "#ffffff"
        assert colors["secondary"] == "#cccccc"
        assert len(colors) == 3


class TestDiscoverSchemes:
    def test_discovers_all_schemes(self):
        schemes = sp._discover_schemes()
        assert "gruvbox" in schemes
        assert "catppuccin" in schemes
        assert "everforest" in schemes
        assert "nord" in schemes
        assert len(schemes) >= 10

    def test_scheme_has_variants(self):
        schemes = sp._discover_schemes()
        gruvbox = schemes["gruvbox"]
        var_ids = {v.id for v in gruvbox.variants}
        assert "medium" in var_ids
        assert "hard" in var_ids
        assert "soft" in var_ids

    def test_variant_has_modes(self):
        schemes = sp._discover_schemes()
        gmedium = next(v for v in schemes["gruvbox"].variants if v.id == "medium")
        assert "dark" in gmedium.modes
        assert "light" in gmedium.modes

    def test_catppuccin_has_accents(self):
        schemes = sp._discover_schemes()
        mocha = next(v for v in schemes["catppuccin"].variants if v.id == "mocha")
        assert "mauve" in mocha.accents
        assert "green" in mocha.accents
        assert "rosewater" in mocha.accents
        assert len(mocha.accents) >= 14

    def test_non_accent_scheme_has_no_accents(self):
        schemes = sp._discover_schemes()
        gmedium = next(v for v in schemes["gruvbox"].variants if v.id == "medium")
        assert gmedium.accents == ()


class TestGetPalette:
    def test_loads_basic_palette(self):
        pal = sp.get_palette("gruvbox", "medium", "dark")
        assert pal.scheme == "gruvbox"
        assert pal.variant == "medium"
        assert pal.mode == "dark"
        assert pal.colors["background"].startswith("#")
        assert pal.colors["primary"].startswith("#")

    def test_loads_accent_palette(self):
        pal = sp.get_palette("catppuccin", "mocha", "dark", accent="mauve")
        assert pal.accent == "mauve"
        assert pal.colors["primary"] == "#cba6f7"

    def test_different_accent_changes_colors(self):
        mauve = sp.get_palette("catppuccin", "mocha", "dark", accent="mauve")
        green = sp.get_palette("catppuccin", "mocha", "dark", accent="green")
        assert mauve.colors["primary"] != green.colors["primary"]
        assert mauve.colors["secondary"] != green.colors["secondary"]

    def test_unknown_scheme_raises(self):
        with pytest.raises(KeyError, match="Unknown scheme 'nope'"):
            sp.get_palette("nope", "medium", "dark")

    def test_unknown_variant_raises(self):
        with pytest.raises(KeyError, match="Unknown variant 'bogus' for scheme 'gruvbox'"):
            sp.get_palette("gruvbox", "bogus", "dark")

    def test_unknown_accent_falls_back(self):
        pal = sp.get_palette("catppuccin", "mocha", "dark", accent="nonexistent")
        assert pal.accent == "nonexistent"
        assert pal.colors["primary"] is not None

    def test_accent_on_non_accent_scheme(self):
        pal = sp.get_palette("gruvbox", "medium", "dark", accent="mauve")
        assert pal.colors is not None

    def test_non_existent_mode_raises(self):
        with pytest.raises(FileNotFoundError):
            sp.get_palette("catppuccin", "mocha", "light")


class TestListSchemes:
    def test_returns_dict(self):
        schemes = sp.list_schemes()
        assert isinstance(schemes, dict)

    def test_includes_known_schemes(self):
        schemes = sp.list_schemes()
        assert "catppuccin" in schemes
        assert "gruvbox" in schemes


class TestResolvePreset:
    def test_two_parts(self):
        assert sp.resolve_preset("gruvbox:medium") == ("gruvbox", "medium", None)

    def test_three_parts(self):
        assert sp.resolve_preset("catppuccin:mocha:mauve") == ("catppuccin", "mocha", "mauve")

    def test_one_part(self):
        assert sp.resolve_preset("default") == ("default", "default", None)

    def test_edge_spaces(self):
        assert sp.resolve_preset(" catppuccin : mocha : mauve ") == (" catppuccin ", " mocha ", " mauve ")
