from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

ASSETS = Path(__file__).resolve().parent.parent / "assets" / "schemes"


@dataclass(frozen=True)
class SchemeVariant:
    id: str
    name: str
    modes: frozenset[str]
    accents: tuple[str, ...] = ()


@dataclass(frozen=True)
class SchemeMeta:
    id: str
    name: str
    variants: tuple[SchemeVariant, ...]


@dataclass
class Palette:
    colors: dict[str, str]
    mode: str
    scheme: str
    variant: str
    accent: str | None = None


def _parse_txt(path: Path) -> dict[str, str]:
    colors: dict[str, str] = {}
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split(None, 1)
        if len(parts) == 2:
            key, val = parts
            colors[key] = f"#{val}" if not val.startswith("#") else val
    return colors


def _discover_schemes() -> dict[str, SchemeMeta]:
    schemes: dict[str, SchemeMeta] = {}

    for scheme_dir in sorted(ASSETS.iterdir()):
        if not scheme_dir.is_dir() or scheme_dir.name.startswith("."):
            continue

        sid = scheme_dir.name
        display_name = sid.capitalize()

        variants: list[SchemeVariant] = []
        for var_dir in sorted(scheme_dir.iterdir()):
            if not var_dir.is_dir() or var_dir.name.startswith("."):
                continue

            modes: set[str] = set()
            accents: set[str] = set()

            for f in var_dir.iterdir():
                if f.suffix != ".txt":
                    continue
                stem = f.stem
                if "-" in stem:
                    maybe_accent, maybe_mode = stem.rsplit("-", 1)
                    if maybe_mode in ("dark", "light"):
                        modes.add(maybe_mode)
                        accents.add(maybe_accent)
                    else:
                        modes.add(stem)
                else:
                    if stem in ("dark", "light"):
                        modes.add(stem)

            if modes:
                vname = var_dir.name.capitalize()
                variants.append(
                    SchemeVariant(
                        id=var_dir.name,
                        name=vname,
                        modes=frozenset(modes),
                        accents=tuple(sorted(accents)),
                    )
                )

        schemes[sid] = SchemeMeta(
            id=sid,
            name=display_name,
            variants=tuple(variants),
        )

    return schemes


SCHEMES: dict[str, SchemeMeta] = _discover_schemes()


def get_palette(scheme: str, variant: str, mode: str, accent: str | None = None) -> Palette:
    if scheme not in SCHEMES:
        raise KeyError(f"Unknown scheme '{scheme}'. Available: {', '.join(SCHEMES)}")

    meta = SCHEMES[scheme]
    var_ids = {v.id for v in meta.variants}
    if variant not in var_ids:
        raise KeyError(f"Unknown variant '{variant}' for scheme '{scheme}'. Available: {', '.join(sorted(var_ids))}")

    if accent:
        filename = f"{accent}-{mode}.txt"
    else:
        filename = f"{mode}.txt"

    txt_path = ASSETS / scheme / variant / filename
    if not txt_path.exists():
        txt_path = ASSETS / scheme / variant / f"{mode}.txt"

    if not txt_path.exists():
        var_info = next(v for v in meta.variants if v.id == variant)
        raise FileNotFoundError(
            f"No {mode} palette for '{scheme}:{variant}'. Available modes: {sorted(var_info.modes)}"
        )

    colors = _parse_txt(txt_path)

    return Palette(colors=colors, mode=mode, scheme=scheme, variant=variant, accent=accent)


def list_schemes() -> dict[str, SchemeMeta]:
    return dict(SCHEMES)


def resolve_preset(spec: str) -> tuple[str, str, str | None]:
    parts = spec.split(":")
    if len(parts) == 3:
        return parts[0], parts[1], parts[2]
    if len(parts) == 2:
        return parts[0], parts[1], None
    if len(parts) == 1:
        return parts[0], "default", None
    raise ValueError(f"Invalid preset spec '{spec}'. Use <scheme>:<variant>[:<accent>]")
