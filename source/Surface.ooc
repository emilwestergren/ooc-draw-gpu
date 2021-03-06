//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

use ooc-math
use ooc-draw
use ooc-opengl
import GpuImage, GpuMap, TraceDrawer

Surface: abstract class {
	size: IntSize2D
	_quad: Quad
	traceDrawer: TraceDrawer
	init: func {
	}
	draw: func ~default (image: GpuImage, map: GpuMap) {
		this _bind()
		this _setResolution(image size)
		this _clear()
		map use()
		image _bind()
		this _quad draw()
		this _unbind()
		this _update()
	}
	draw: func ~customResolution (image: GpuImage, map: GpuMap, resolution: IntSize2D) {
		this _bind()
		this _setResolution(resolution)
		this _clear()
		map use()
		image _bind()
		this _quad draw()
		this _unbind()
		this _update()
	}
	drawLines: func (transform: FloatTransform2D, screenSize: IntSize2D) {
		if(this traceDrawer == null)
			this traceDrawer = TraceDrawer new(screenSize)
		this _bind()
		this traceDrawer add(transform)
		this traceDrawer draw()
		this _unbind()
		this _update()
	}

	_clear: abstract func
	_bind: abstract func
	_setResolution: func (resolution: IntSize2D)
	_unbind: func
	_update: func
}
