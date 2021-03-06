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

class ModelingView: UIView, UIGestureRecognizerDelegate {

    var lastPoint: CGPoint!
    var freeFormLines: [FreeFormLine] = []
    var contributionLines: [FreeFormLine] = []
    var strockID : Int = 1
    var touchPoints : [DollarPoint] = []
    var startPoint : CGPoint!
    var endPoint : CGPoint!
    var touchTimer : NSTimer!


    required init(coder aDecoder: NSCoder) {
        startPoint = CGPointMake(0.0, 0.0)
        endPoint = CGPointMake(0.0, 0.0)
        super.init(coder: aDecoder)
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action:Selector("handlePinch:"))
        pinchRecognizer.delegate = self
        self.addGestureRecognizer(pinchRecognizer)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if touchTimer != nil{
            touchTimer.invalidate()
        }
        
        if let touch = touches.first as? UITouch {
            let newPoint = touch.locationInView(self)
            updateLastPoint(newPoint)
            addPoint(self.strockID, x: Float(lastPoint.x), y: Float(lastPoint.y))
            self.updateStartPoint(self.lastPoint)
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            let newPoint = touch.locationInView(self)
    
            freeFormLines.append(FreeFormLine(start: lastPoint, end: newPoint))
            updateLastPoint(newPoint)
            
            addPoint(self.strockID, x: Float(lastPoint.x), y: Float(lastPoint.y))
            calculateStartPointFromSecondPoint(lastPoint)
            calculateEndPointFromSecondPoint(lastPoint)
            
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            
            let newPoint = touch.locationInView(self)
            updateLastPoint(newPoint)
            addPoint(self.strockID++, x: Float(lastPoint.x), y: Float(lastPoint.y))

            calculateStartPointFromSecondPoint(lastPoint)
            calculateEndPointFromSecondPoint(lastPoint)
            
            touchTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "recognize", userInfo: nil, repeats: false)
        }
    }

    override func drawRect(rect: CGRect) {
        // where the magic happens, drawing a line between two points on the view
        // In order to show feedback
        var context = UIGraphicsGetCurrentContext()
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0)
        CGContextSetLineCap(context, kCGLineCapRound)
        CGContextSetLineWidth(context, 2.0)
        
        for line in freeFormLines{
            CGContextMoveToPoint(context, line.startX, line.startY)
            CGContextAddLineToPoint(context, line.endX, line.endY)
        }
        CGContextStrokePath(context)
        
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0)

        for line in contributionLines{
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
        var width = max(endPoint.x, startPoint.x) - min(endPoint.x, startPoint.x)
        var height = max(endPoint.y, startPoint.y) - min(endPoint.y, startPoint.y)

        switch type {
        case "Softgoal":
            var newView = GRLSoftgoalView(frame: CGRectMake(self.startPoint.x, self.startPoint.y, width, height))
            newView.backgroundColor = UIColor(red: 255.0, green:255.0, blue: 255.0, alpha: 0.0)
            self.addSubview(newView)
            self.clearPoints()
        case "Contribution":
            self.drawContribution()
            self.clearPoints()
        case "Delete":
            var pointX = (min(endPoint.x, startPoint.x) + max(endPoint.x, startPoint.x)) / 2
            var pointY = (min(endPoint.y, startPoint.y) + max(endPoint.y, startPoint.y)) / 2
            var view = self.hitTest(CGPointMake(pointX, pointY), withEvent: nil)
            if view != self{
                view?.removeFromSuperview()
            }
            self.clearPoints()
            
        case "Goal":
            var goalView = GRLGoalView(frame: CGRectMake(self.startPoint.x, self.startPoint.y, width, height))
            goalView.backgroundColor = UIColor(red: 255.0, green:255.0, blue: 255.0, alpha: 0.0)
            self.addSubview(goalView)
            self.clearPoints()
        default:
            println("Unknown type")
            self.clearPoints()
        }
    }
    
    func calculateStartPointFromSecondPoint(secondPoint: CGPoint){
        self.startPoint.x = min(self.startPoint.x, secondPoint.x)
        self.startPoint.y = min(self.startPoint.y, secondPoint.y)
    }

    func calculateEndPointFromSecondPoint(secondPoint: CGPoint){
        self.endPoint.x = max(self.endPoint.x, secondPoint.x)
        self.endPoint.y = max(self.endPoint.y, secondPoint.y)
    }
    
    func handlePinch(recognizer : UIPinchGestureRecognizer){
        // do nothing, otherwise the feedback drawing will 
        // draw lines everywhere on the view.
    }
    
    func clearPoints(){
        self.touchPoints = []
        freeFormLines = []
        self.startPoint = CGPointMake(0.0, 0.0)
        self.endPoint = CGPointMake(0.0, 0.0)
        self.setNeedsDisplay()
    }
    
    func drawContribution(){
        for line in freeFormLines{
            contributionLines.append(line)
        }
    }
}