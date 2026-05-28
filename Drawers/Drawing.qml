import QtQuick

Canvas {
	id: root

	property color penColor: "white"
	property real penWidth: 4
	property var points: []

	function clear(): void {
		var ctx = getContext('2d');
		root.points = [];
		ctx.reset();
		root.requestPaint();
	}

	renderStrategy: Canvas.Cooperative

	onPaint: {
		if (points.length < 2)
			return;
		var ctx = root.getContext('2d');
		ctx.save();
		ctx.lineWidth = root.penWidth;
		ctx.strokeStyle = root.penColor;
		ctx.lineJoin = "round";
		ctx.lineCap = "round";
		ctx.beginPath();
		ctx.moveTo(points[0].x, points[0].y);
		for (var i = 1; i < points.length; i++)
			ctx.lineTo(points[i].x, points[i].y);
		ctx.stroke();
		points = points.slice(points.length - 2);
		ctx.restore();
	}
}
