import QtQuick
import qs.Config

AnchorAnimation {
	enum Type {
		StandardSmall = 0,
		Standard,
		StandardLarge,
		StandardExtraLarge,
		EmphasizedSmall,
		Emphasized,
		EmphasizedLarge,
		EmphasizedExtraLarge,
		FastSpatial,
		DefaultSpatial,
		SlowSpatial
	}

	property int type: AnchorAnim.DefaultSpatial

	duration: {
		if (type < AnchorAnim.StandardSmall || type > AnchorAnim.SlowSpatial)
			return Appearance.anim.durations.expressiveDefaultSpatial;

		if (type == AnchorAnim.FastSpatial)
			return Appearance.anim.durations.expressiveFastSpatial;
		if (type == AnchorAnim.DefaultSpatial)
			return Appearance.anim.durations.expressiveDefaultSpatial;
		if (type == AnchorAnim.SlowSpatial)
			return Appearance.anim.durations.large;

		const types = ["small", "normal", "large", "extraLarge"];
		const idx = type % 4;
		return Appearance.anim.durations[types[idx]];
	}
	easing.bezierCurve: {
		if (type == AnchorAnim.FastSpatial)
			return Appearance.anim.curves.expressiveFastSpatial;
		if (type == AnchorAnim.DefaultSpatial)
			return Appearance.anim.curves.expressiveDefaultSpatial;
		if (type == AnchorAnim.SlowSpatial)
			return Appearance.anim.curves.expressiveSlowSpatial;

		if (type >= AnchorAnim.StandardSmall && type <= AnchorAnim.StandardExtraLarge)
			return Appearance.anim.curves.standard;
		if (type >= AnchorAnim.EmphasizedSmall && type <= AnchorAnim.EmphasizedExtraLarge)
			return Appearance.anim.curves.emphasized;

		return Appearance.anim.curves.expressiveDefaultSpatial;
	}
}
