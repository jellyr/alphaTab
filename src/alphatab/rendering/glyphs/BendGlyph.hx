package alphatab.rendering.glyphs;
import alphatab.model.BendPoint;
import alphatab.model.Note;
import alphatab.platform.ICanvas;
import alphatab.rendering.Glyph;
import alphatab.rendering.TabBarRenderer;

class BendGlyph extends Glyph
{
	private var _note:Note;
	private var _width:Int;
	private var _height:Int;
	
	public function new(n:Note, width:Int, height:Int) 
	{
		super(0, 0);
		_note = n;
		_width = width;
		_height = height;
	}
	
	public override function paint(cx:Int, cy:Int, canvas:ICanvas):Dynamic 
	{
		var r:TabBarRenderer = cast renderer;
		var res = renderer.getResources();
		// calculate offsets per step
		var dX:Float = _width / BendPoint.MAX_POSITION;
		var maxValue = 0;
		for (i in 0 ... _note.bendPoints.length)  
		{
			if (_note.bendPoints[i].value > maxValue) 
			{
				maxValue = _note.bendPoints[i].value;
			}
		}

		var dY:Float = _height / maxValue;
		
		var xx = cx + x;
		var yy = cy + y + r.getNoteY(_note); 

		canvas.beginPath();
		for (i in 0 ... _note.bendPoints.length - 1)
		{
			var firstPt:BendPoint = _note.bendPoints[i];
			var secondPt:BendPoint = _note.bendPoints[i + 1];

			// don't draw a line if there's no offset
			if (firstPt.value == secondPt.value && i == _note.bendPoints.length - 2) continue;

			// draw bezier lien from first to second point
			var x1 = xx + (dX * firstPt.offset);
			var y1 = yy - (dY * firstPt.value);
			var x2 = xx + (dX * secondPt.offset);
			var y2 = yy - (dY * secondPt.value);
			var hx = x1 + (x2 - x1);
			var hy = yy - (dY * firstPt.value);
			canvas.moveTo(x1, y1);
			canvas.bezierCurveTo(hx, hy, x2, y2, x2, y2);
			canvas.stroke();

			// what type of arrow? (up/down)
			var arrowSize:Float = 6 * getScale();
			if (secondPt.value > firstPt.value)
			{
				canvas.beginPath();
				canvas.moveTo(x2, y2);
				canvas.lineTo(x2 - arrowSize * 0.5, y2 + arrowSize); 
				canvas.lineTo(x2 + arrowSize * 0.5, y2 + arrowSize);
				canvas.closePath();
				canvas.fill();
			}
			else if (secondPt.value != firstPt.value)
			{
				canvas.beginPath();
				canvas.moveTo(x2, y2);
				canvas.lineTo(x2 - arrowSize * 0.5, y2 - arrowSize); 
				canvas.lineTo(x2 + arrowSize * 0.5, y2 - arrowSize);
				canvas.closePath();
				canvas.fill();
			}
			canvas.stroke();
							
			if (secondPt.value != 0)
			{
				var dV:Float = (secondPt.value - firstPt.value);  
				var up:Bool = dV > 0;
				dV = Math.abs(dV);
				
				// calculate label
				var s:String = "";
				// Full Steps 
				if (dV == 4)
				{
					s = "full";
					dV -= 4;
				}
				else if (dV > 4)
				{
					s += Std.string(Math.floor(dV / 4)) + " ";
					// Quaters
					dV -= Math.floor(dV);
				}

				if (dV > 0) {
					s += Std.string(dV) + "/4";
				}
				
				if (!up) 
				{
					s = "-" + s;
				}

				// draw label
				canvas.setFont(res.tablatureFont);
				var size:Float = canvas.measureText(s);
				var y:Float = up ? y2 - res.tablatureFont.getSize() - (2 * getScale()) : y2 + (2 * getScale());
				var x:Float = x2 - size / 2;

				canvas.fillText(s, x, y);
			}
		}
	}
}