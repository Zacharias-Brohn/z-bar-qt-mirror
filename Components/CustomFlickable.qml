import QtQuick
import qs.Helpers

Flickable {
	id: root

	interactive: !Visibilities.getForActive().isDrawing
	maximumFlickVelocity: 3000

	rebound: Transition {
		Anim {
			properties: "x,y"
		}
	}
}
