import qs.Config

CustomText {
	id: root

	readonly property list<int> allowed: [20, 24, 40, 48]
	property real fill: 0
	property int grade: DynamicColors.light ? 0 : -25
	readonly property int opsz: clampOpsz(optical)
	property int optical: fontInfo.pixelSize

	function clampOpsz(value): int {
		return allowed.reduce((closest, current) => {
			return Math.abs(current - value) < Math.abs(closest - value) ? current : closest;
		});
	}

	font.family: "Material Symbols Rounded"
	font.pointSize: Appearance.font.size.larger
	font.variableAxes: ({
			FILL: fill,
			GRAD: grade,
			opsz: opsz,
			wght: fontInfo.weight
		})
}
