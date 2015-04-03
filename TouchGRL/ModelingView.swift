//
//  ModelingView.swift
//  TouchGRL
//
//  Created by Mohamed El-Halawani on 2015-02-07.
//  
//  This class represent the modeling area of the application main view.
//  Please check https://www.youtube.com/watch?v=8KV1o9hPF5E for explanation
//
//

import UIKit

class ModelingView: UIView {

    var lastPoint: CGPoint!
    var freeFormLines: [FreeFormLine] = []
    var strockID : Int = 1
    var touchPoints : [DollarPoint] = []
    var startPoint : CGPoint!
    var endPoint : CGPoint!


    required init(coder aDecoder: NSCoder) {
        startPoint = CGPointMake(0.0, 0.0)
        endPoint = CGPointMake(0.0, 0.0)
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        updateLastPoint(touches.anyObject()?.locationInView(self))
        addPoint(self.strockID, x: Float(lastPoint.x), y: Float(lastPoint.y))
        self.updateStartPoint(self.lastPoint)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {

        var newPoint = touches.anyObject()?.locationInView(self)
        freeFormLines.append(FreeFormLine(start: lastPoint, end: newPoint!))
        updateLastPoint(newPoint)
        
        addPoint(self.strockID, x: Float(lastPoint.x), y: Float(lastPoint.y))
        calculateStartPointFromSecondPoint(lastPoint)
        
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        updateLastPoint(touches.anyObject()?.locationInView(self))
        addPoint(self.strockID++, x: Float(lastPoint.x), y: Float(lastPoint.y))
        self.recognize()
    }

    override func drawRect(rect: CGRect) {
        // where the magic happens, drawing a line between two points on the view
        var context = UIGraphicsGetCurrentContext()
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0)
        CGContextSetLineCap(context, kCGLineCapRound)
        CGContextSetLineWidth(context, 2.0)
        
        for line in freeFormLines{
            CGContextMoveToPoint(context, line.startX, line.startY)
            CGContextAddLineToPoint(context, line.endX, line.endY)
        }
        CGContextStrokePath(context)
    }
    
    func updateLastPoint(newPoint: CGPoint?){
        self.lastPoint = newPoint
    }
    
    func addPoint(strockID: Int, x: Float, y: Float){
        var point : DollarPoint = DollarPoint()
        point.id = strockID
        point.x = x
        point.y = y
        touchPoints.append(point)
    }
    
    func updateStartPoint(lastPoint: CGPoint){
        self.startPoint = lastPoint
    }
    
    func recognize(){
        var recognizer : RecognizeController = RecognizeController()
        var result = recognizer.recognize(self.touchPoints)
        drawGRLNotation(result.name)
    }
    
    func drawGRLNotation(type: NSString){
        var newView: GRLView
        
        switch type {
        case "Softgoal":
            newView = GRLSoftgoalView(frame: CGRectMake(15, 15, 300, 150))
            newView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            self.addSubview(newView)
            self.touchPoints = []
            freeFormLines = []
        default:
            println("Unknown type")
        }
    }
    
    func calculateStartPointFromSecondPoint(secondPoint: CGPoint){
        self.startPoint.x = min(self.startPoint.x, secondPoint.x)
        self.startPoint.y = min(self.startPoint.y, secondPoint.y)
        println("StartX= \(startPoint.x) StartY= \(startPoint.y)")
    }
}