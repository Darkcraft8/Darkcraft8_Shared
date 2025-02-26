if not canvas then canvas = {} end
if not canvasStorage then canvasStorage = {} end

canvas.setCanvas = function(canvasWidgetName)
    if type(canvasWidgetName) == "string" then
        canvasStorage.widget = widget.bindCanvas(canvasWidgetName)
    else
        canvasStorage.widget = canvasWidgetName
    end
end
--- drawMethod quickies
-- set canvasStorage.widget to your canvas using widget.bindCanvas() or any similar function
canvas.clear = function() canvasStorage.widget:clear() end
canvas.size = function() return canvasStorage.widget:size() end
canvas.mousePosition = function() return canvasStorage.widget:mousePosition() end

canvas.drawImage = function(_, image, position, scale, color, centered) canvasStorage.widget:drawImage(image, position, scale, color, centered) end
canvas.drawImageDrawable = function(_, image, position, scale, color, rotation) canvasStorage.widget:drawImageDrawable(image, position, scale, color, rotation) end
canvas.drawImageRect = function(_, texName, texCoords, screenCoords, color) canvasStorage.widget:drawImageRect(texName, texCoords, screenCoords, color) end
canvas.drawPoly = function(_, poly, color, lineWidth) canvasStorage.widget:drawPoly(poly, color, lineWidth) end
canvas.drawRect = function(_, rect, color) canvasStorage.widget:drawRect(rect, color) end
canvas.drawText = function(_, text, textPositioning, fontSize, color) canvasStorage.widget:drawText(text, textPositioning, fontSize, color) end
canvas.drawTiledImage = function(_, image, offset, screenCoords, scale, color) canvasStorage.widget:drawTiledImage(image, offset, screenCoords, scale, color) end
canvas.drawTriangles = function(_, triangles, color) canvasStorage.widget:drawTriangles(triangles, color) end

    --textPositioning = {
    --    position = {0, 0}
    --    horizontalAnchor = "left", -- left, mid, right
    --    verticalAnchor = "top", -- top, mid, bottom
    --    wrapWidth = nil -- wrap width in pixels or nil
    --}