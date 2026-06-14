import QtQuick
import qs.Config

NumberAnimation {
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
		SlowSpatial,
		FastEffects,
		DefaultEffects,
		SlowEffects
	}

	property int type: Anim.DefaultSpatial

	duration: {
		if (type < Anim.StandardSmall || type > Anim.SlowEffects)
			return Appearance.anim.durations.normal;

		if (type === Anim.FastSpatial)
			return Appearance.anim.durations.expressiveFastSpatial;
		if (type === Anim.DefaultSpatial)
			return Appearance.anim.durations.expressiveDefaultSpatial;
		if (type === Anim.SlowSpatial)
			return Appearance.anim.durations.large;
		if (type === Anim.FastEffects)
			return Appearance.anim.durations.expressiveFastEffects;
		if (type === Anim.DefaultEffects)
			return Appearance.anim.durations.expressiveEffects;
		if (type === Anim.SlowEffects)
			return Appearance.anim.durations.expressiveSlowEffects;

		const types = ["small", "normal", "large", "extraLarge"];
		const idx = type % 4;
		return Appearance.anim.durations[types[idx]];
	}
	easing.bezierCurve: {
		if (type === Anim.FastSpatial)
			return Appearance.anim.curves.expressiveFastSpatial;
		if (type === Anim.DefaultSpatial)
			return Appearance.anim.curves.expressiveDefaultSpatial;
		if (type === Anim.SlowSpatial)
			return Appearance.anim.curves.expressiveSlowSpatial;
		if (type === Anim.FastEffects)
			return Appearance.anim.curves.expressiveFastEffects;
		if (type === Anim.DefaultEffects)
			return Appearance.anim.curves.expressiveDefaultEffects;
		if (type === Anim.SlowEffects)
			return Appearance.anim.curves.expressiveSlowEffects;

		if (type >= Anim.EmphasizedSmall && type <= Anim.EmphasizedExtraLarge)
			return Appearance.anim.curves.emphasized;
		return Appearance.anim.curves.standard;
	}
}
