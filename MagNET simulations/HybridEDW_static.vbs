const PI = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067

' Materials

webMaterial = "Aluminium 6061-T6"
webConductivity = 24940400
plateMaterial = "Aluminium 6101-T61"
plateCondutivity = 34220600
magnetMaterial = "N50"

' Track dimensions
const webWidth = 127
const webThickness = 12.7
const plateWidth = 127
const plateThickness = 12.7

const BUILD_WITH_SYMMETRY = False	' Build only half of the track and one wheel, with symmetry conditions
const runSimulation = False			' Automatically run simulation

' EDW dimensions
numMagnets = 20				' Number of magnets per wheel
rollAngle = 45.0 * PI / 180.0		' Change in angle between consecutive magnets (rad)
innerRadius = 92.6777			' Inner radius of wheel
magnetWidth = 35.355					' Width of magnets
magnetDepth = 25					' Depth of magnets
levitationHeight = 10				' Height from lowest point of magnets to conducting plate
railClearance = 6					' Clearance from magnets to rail
wheelAngle = 45.0 * PI / 180.0   	' Tilt of entire wheel assembly towards rail (from horizontal) (rad)
magnetAngle = 45.0 * PI / 180.0  	' Tilt of individual magnets outwards (from pointing downwards) (rad)
offsetX = 0.0						' Offset of both wheels laterally to test for guidance force (only works when simulating without symmetry)

numWheels = 1
spaceBetweenWheels = 100.0

If BUILD_WITH_SYMMETRY Then
    offsetX = 0.0
End If

magneticCircumference = 1.04 * innerRadius*PI*2.0 / 1000.0		' Magnetic circumference of wheel (important for accurate slip speeds)

outerRadius = innerRadius + magnetWidth*Cos(magnetAngle)
wheelsLength = outerRadius * 2.0 * numWheels + spaceBetweenWheels * (numWheels - 1)
wheelOffsetZ = outerRadius * 2.0 + spaceBetweenWheels
wheelOffsetAngle = wheelOffsetZ / magneticCircumference * PI * 2.0

' Air boundaries

airYCut = 0.0
airXCut = 0.0
airYMin = -10.0
airZClearance = 40.0
airZ = wheelsLength / 2.0 + airZClearance

' Mesh resolutions
airRailBoundary = 1
airResolution = 8
aluminiumResolution = 6
magnetResolution = 1
railSurfaceResolution = 3
plateSurfaceResolution = 3
magnetFaceResolution = 1
useHAdaption = False
usePAdaption = False

' Magnet geometry

Bx = -railClearance - webThickness/2.0
Ay = levitationHeight + 2.0*innerRadius*Sin(wheelAngle) + plateThickness
Ax = Bx - magnetWidth*Cos(wheelAngle + magnetAngle)
By = Ay + magnetWidth*Sin(wheelAngle + magnetAngle)
Cx = Bx - magnetDepth*Sin(wheelAngle + magnetAngle)
Cy = By + magnetDepth*Cos(wheelAngle + magnetAngle)
Dx = Ax - magnetDepth*Sin(wheelAngle + magnetAngle)
Dy = Ay + magnetDepth*Cos(wheelAngle + magnetAngle)

magnetMidX = (Ax + Bx + Cx + Dx) / 4.0
magnetMidY = (Ay + By + Cy + Dy) / 4.0

Px = -magnetWidth*Cos(wheelAngle + magnetAngle) - innerRadius*Cos(wheelAngle) - railClearance - webThickness/2.0
Py = innerRadius*Sin(wheelAngle) + levitationHeight + plateThickness
axisX = -Sin(wheelAngle)
axisY = Cos(wheelAngle)

magnetLevitationFaceX = -Px + innerRadius*Cos(wheelAngle) + magnetWidth/2.0*Cos(wheelAngle - magnetAngle)

outerRadius = innerRadius + magnetWidth*Cos(magnetAngle)

Set objExcel = CreateObject("Excel.Application")
objExcel.Application.Visible = True


Call newDocument()
Call SetLocale("en-us")
Call getDocument().setDefaultLengthUnit("Millimeters")
Set view = getDocument().getView()

' Air

If BUILD_WITH_SYMMETRY Then
	Call view.newLine(-magnetLevitationFaceX - plateWidth/2.0 - 1, airYMin, -magnetLevitationFaceX - plateWidth/2.0 - 1, plateThickness + airYCut + 1)
	Call view.newLine(-magnetLevitationFaceX - plateWidth/2.0 - 1, plateThickness + airYCut + 1, -webThickness/2.0 - airZCut - 1, magnetMidY + webWidth/2.0 + 1)
	Call view.newLine(-webThickness/2.0 - airZCut - 1, magnetMidY + webWidth/2.0 + 1, 0, magnetMidY + webWidth/2.0 + 1)
	Call view.newLine(0, magnetMidY + webWidth/2.0 + 1, 0, magnetMidY - webWidth/2.0 - 1)
	Call view.newLine(0, magnetMidY - webWidth/2.0 - 1, -magnetLevitationFaceX + plateWidth/2.0 + 1, airYMin)
	Call view.newLine(-magnetLevitationFaceX + plateWidth/2.0 + 1, airYMin, -magnetLevitationFaceX - plateWidth/2.0 - 1, airYMin)
Else
	Call view.newLine(-magnetLevitationFaceX - plateWidth/2.0 - 1, airYMin, -magnetLevitationFaceX - plateWidth/2.0 - 1, magnetMidY + webWidth/2.0 + 1)
	Call view.newLine(-magnetLevitationFaceX - plateWidth/2.0 - 1, magnetMidY + webWidth/2.0 + 1, magnetLevitationFaceX + plateWidth/2.0 + 1, magnetMidY + webWidth/2.0 + 1)
	Call view.newLine(magnetLevitationFaceX + plateWidth/2.0 + 1, magnetMidY + webWidth/2.0 + 1, magnetLevitationFaceX + plateWidth/2.0 + 1, airYMin)
	Call view.newLine(magnetLevitationFaceX + plateWidth/2.0 + 1, airYMin, -magnetLevitationFaceX - plateWidth/2.0 - 1, airYMin)
End If

Call view.getSlice().moveInALine(-airZ - motionLength - airRailBoundary)
Call view.selectAt(-1, magnetMidY, infoSetSelection, Array(infoSliceSurface))
Call view.makeComponentInALine(airZ*2 + motionLength*2 + airRailBoundary*2, Array("Outer Air"), "Name=AIR", infoMakeComponentUnionSurfaces Or infoMakeComponentRemoveVertices)
Call getDocument().setMaxElementSize("Outer Air", airResolution)
Call view.getSlice().moveInALine(airZ + motionLength + airRailBoundary)
Call getDocument().getView().setObjectVisible("Outer Air", False)

Call view.selectAll(infoSetSelection, Array(infoSliceLine))
Call view.deleteSelection()

If BUILD_WITH_SYMMETRY Then
	Call getDocument().createBoundaryCondition(Array("Outer Air,Face#5"), "BoundaryCondition#1")
	Call getDocument().setMagneticFieldNormal("BoundaryCondition#1")
End If

' Web

If BUILD_WITH_SYMMETRY Then
	Call view.newLine(-webThickness/2.0, magnetMidY - webWidth/2.0, 0, magnetMidY - webWidth/2.0)
	Call view.newLine(0, magnetMidY - webWidth/2.0, 0, magnetMidY + webWidth/2.0)
	Call view.newLine(0, magnetMidY + webWidth/2.0, -webThickness/2.0, magnetMidY + webWidth/2.0)
	Call view.newLine(-webThickness/2.0, magnetMidY + webWidth/2.0, -webThickness/2.0, magnetMidY - webWidth/2.0)
Else
	Call view.newLine(-webThickness/2.0, magnetMidY - webWidth/2.0, webThickness/2.0, magnetMidY - webWidth/2.0)
	Call view.newLine(webThickness/2.0, magnetMidY - webWidth/2.0, webThickness/2.0, magnetMidY + webWidth/2.0)
	Call view.newLine(webThickness/2.0, magnetMidY + webWidth/2.0, -webThickness/2.0, magnetMidY + webWidth/2.0)
	Call view.newLine(-webThickness/2.0, magnetMidY + webWidth/2.0, -webThickness/2.0, magnetMidY - webWidth/2.0)
End If

' Plate(s)

Call view.newLine(-magnetLevitationFaceX - plateWidth/2.0, 0, -magnetLevitationFaceX + plateWidth/2.0, 0)
Call view.newLine(-magnetLevitationFaceX + plateWidth/2.0, 0, -magnetLevitationFaceX + plateWidth/2.0, plateThickness)
Call view.newLine(-magnetLevitationFaceX + plateWidth/2.0, plateThickness, -magnetLevitationFaceX - plateWidth/2.0, plateThickness)
Call view.newLine(-magnetLevitationFaceX - plateWidth/2.0, plateThickness, -magnetLevitationFaceX - plateWidth/2.0, 0)

If NOT(BUILD_WITH_SYMMETRY) Then
	Call view.newLine(magnetLevitationFaceX - plateWidth/2.0, 0, magnetLevitationFaceX + plateWidth/2.0, 0)
	Call view.newLine(magnetLevitationFaceX + plateWidth/2.0, 0, magnetLevitationFaceX + plateWidth/2.0, plateThickness)
	Call view.newLine(magnetLevitationFaceX + plateWidth/2.0, plateThickness, magnetLevitationFaceX - plateWidth/2.0, plateThickness)
	Call view.newLine(magnetLevitationFaceX - plateWidth/2.0, plateThickness, magnetLevitationFaceX - plateWidth/2.0, 0)
End If

Call view.getSlice().moveInALine(-airZ - motionLength/2.0)

Call view.selectAt(-1, magnetMidY, infoSetSelection, Array(infoSliceSurface))
Call view.makeComponentInALine(airZ*2 + motionLength, Array("Rail"), "Name=" & webMaterial, infoMakeComponentUnionSurfaces Or infoMakeComponentRemoveVertices)
Call getDocument().setMaxElementSize("Rail", aluminiumResolution)

Call view.selectAt(-magnetLevitationFaceX, plateThickness/2.0, infoSetSelection, Array(infoSliceSurface))
Call view.makeComponentInALine(airZ*2 + motionLength, Array("Plate1"), "Name=" & plateMaterial, infoMakeComponentUnionSurfaces Or infoMakeComponentRemoveVertices)
Call getDocument().setMaxElementSize("Plate1", aluminiumResolution)

If NOT(BUILD_WITH_SYMMETRY) Then
	Call view.selectAt(magnetLevitationFaceX, plateThickness/2.0, infoSetSelection, Array(infoSliceSurface))
	Call view.makeComponentInALine(airZ*2 + motionLength, Array("Plate2"), "Name=" & plateMaterial, infoMakeComponentUnionSurfaces Or infoMakeComponentRemoveVertices)
	Call getDocument().setMaxElementSize("Plate2", aluminiumResolution)
End If

Call view.getSlice().moveInALine(airZ + motionLength/2.0)
Call view.selectAll(infoSetSelection, Array(infoSliceLine))
Call view.deleteSelection()

If NOT(BUILD_WITH_SYMMETRY) Then
	Call getDocument().setMaxElementSize("Rail,Face#4", railSurfaceResolution)
	Call getDocument().setMaxElementSize("Rail,Face#6", railSurfaceResolution)
Else
	Call getDocument().setMaxElementSize("Rail,Face#6", railSurfaceResolution)
End If

Call getDocument().setMaxElementSize("Plate1,Face#5", plateSurfaceResolution)

If NOT(BUILD_WITH_SYMMETRY) Then
	Call getDocument().setMaxElementSize("Plate2,Face#5", plateSurfaceResolution)
End If


' Magnets

symmetrySides = 2
if (BUILD_WITH_SYMMETRY) Then
    symmetrySides = 1
End If

Call view.newLine(Ax, Ay, Bx, By)
Call view.newLine(Bx, By, Cx, Cy)
Call view.newLine(Cx, Cy, Dx, Dy)
Call view.newLine(Dx, Dy, Ax, Ay)

'Call view.newLine(Px, Py, Px + axisX*100, Py + axisY*100)

Call view.getSlice().moveInALine(wheelsLength / 2.0 - outerRadius)

For n = 1 To numWheels

    ReDim MagnetsA(numMagnets - 1)

    Call view.getSlice().moveInAnArc(Px, Py, axisX, axisY, -360.0 / numMagnets / 2.0 - wheelOffsetAngle*(n - 1))

    For i = 1 To numMagnets
        circleAngle = PI * 2.0 * (i - 1) / numMagnets

        ' Circumferential vector
        x1 = -Cos(wheelAngle)*Sin(circleAngle)
        y1 = -Sin(wheelAngle)*Sin(circleAngle)
        z1 = -Cos(circleAngle)

        ' Vector normal to outwards face
        x2 = Sin(wheelAngle + magnetAngle)*(Cos(circleAngle) + Sin(wheelAngle)*Sin(wheelAngle)*(1 - Cos(circleAngle))) + Cos(wheelAngle + magnetAngle)*Sin(wheelAngle)*Cos(wheelAngle)*(1 - Cos(circleAngle))
        y2 = -Sin(wheelAngle + magnetAngle)*Sin(wheelAngle)*Cos(wheelAngle)*(1 - Cos(circleAngle)) - Cos(wheelAngle + magnetAngle)*(Cos(circleAngle) + Cos(wheelAngle)*Cos(wheelAngle)*(1 - Cos(circleAngle)))
        z2 = -Sin(wheelAngle + magnetAngle)*Cos(wheelAngle)*Sin(circleAngle) + Cos(wheelAngle + magnetAngle)*Sin(wheelAngle)*Sin(circleAngle)

        magnetizationAngle = -(i - 1) * rollAngle

        x_hat = x1*Sin(magnetizationAngle) + x2*Cos(magnetizationAngle)
        y_hat = y1*Sin(magnetizationAngle) + y2*Cos(magnetizationAngle)
        z_hat = z1*Sin(magnetizationAngle) + z2*Cos(magnetizationAngle)

        direction = "[" & x_hat & "," & y_hat & "," & z_hat & "]"

        Call view.selectAll(infoSetSelection, Array(infoSliceSurface))

        Call view.makeComponentInAnArc(Px, Py, axisX, axisY, 360.0 / numMagnets, Array("MagnetA" & n & "#" & i), "Name=" & magnetMaterial & ";Type=Uniform;Direction=" & direction, infoMakeComponentUnionSurfaces Or infoMakeComponentRemoveVertices)

        Call getDocument().setMaxElementSize("MagnetA" & n & "#" & i, magnetResolution)
        Call getDocument().setMaxElementSize("MagnetA" & n & "#" & i & ",Face#4", magnetFaceResolution)

        Call view.getSlice().moveInAnArc(Px, Py, axisX, axisY, 360.0 / numMagnets)

        MagnetsA(i - 1) = "MagnetA" & n & "#" & i
    Next

    Call getDocument().shiftComponent(MagnetsA, offsetX, 0, 0, 1)

    Call view.getSlice().moveInAnArc(Px, Py, axisX, axisY, 360.0 / numMagnets / 2.0 + wheelOffsetAngle*(n - 1))

Next


' Scale view to fit

Call getDocument().getView().setScaledToFit(True)

Call getDocument().getView().selectObject("Rail", infoSetSelection)
Call getDocument().getView().deleteSelection()
Call getDocument().getView().selectObject("Plate1", infoSetSelection)
Call getDocument().getView().deleteSelection()
Call getDocument().getView().selectObject("Plate2", infoSetSelection)
Call getDocument().getView().deleteSelection()

' Run Simulations


Call getDocument().solveStatic3d()
