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
numMagnets = 24						' Number of magnets per wheel
rollAngle = 45.0 * PI / 180.0		' Change in angle between consecutive magnets (rad)
innerRadius = 200 / 2.0				' Inner radius of wheel
magnetWidth = 50.8					' Width of magnets
magnetDepth = 25.4					' Depth of magnets
levitationHeight = 10				' Height from lowest point of magnets to conducting plate
railClearance = 6					' Clearance from magnets to rail
wheelAngle = 45.0 * PI / 180.0   	' Tilt of entire wheel assembly towards rail (from horizontal) (rad)
magnetAngle = 45.0 * PI / 180.0  	' Tilt of individual magnets outwards (from pointing downwards) (rad)
offsetX = 0.0						' Offset of both wheels laterally to test for guidance force (only works when simulating without symmetry)

numWheels = 4
spaceBetweenWheels = 100.0

If BUILD_WITH_SYMMETRY Then
    offsetX = 0.0
End If

' Speeds in m/s
speed = 25.0						' Speed of pod
slipSpeed = 30.0					' Slip speed if numSpeedSteps = 1
minSlipSpeed = 10.0					' Starting test slip speed
maxSlipSpeed = 20.0 				' Ending test slip speed
numSpeedSteps = 3					' Number of tests, slip speed is linearly spaces from minSlipSpeed to maxSlipSpeed

solveStepsPerMagnet = 10.0	        ' Number of steps needed for wheel to rotate the angle of one magnet
numSteps = 10*10				    ' Number of simulation steps

If (numSpeedSteps = 1) Then
	minSlipSpeed = slipSpeed
End If

magneticCircumference = 1.04 * innerRadius*PI*2.0 / 1000.0		' Magnetic circumference of wheel (important for accurate slip speeds)

outerRadius = innerRadius + magnetWidth*Cos(magnetAngle)
wheelsLength = outerRadius * 2.0 * numWheels + spaceBetweenWheels * (numWheels - 1)
wheelOffsetZ = outerRadius * 2.0 + spaceBetweenWheels
wheelOffsetAngle = wheelOffsetZ / magneticCircumference * PI * 2.0


' Use min rps to calculate max solveStep for max rail length
rps = (speed + minSlipSpeed) / magneticCircumference
solveStep = 1000.0 / (rps * numMagnets * solveStepsPerMagnet)

motionLength = speed * (solveStep * numSteps)

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
magnetResolution = 7
railSurfaceResolution = 3
plateSurfaceResolution = 3
magnetFaceResolution = 3
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

' Add Aluminium Materials

If NOT getUserMaterialDatabase().isMaterialInDatabase(webMaterial) Then
	Call getUserMaterialDatabase().newMaterial(webMaterial)
	Call getUserMaterialDatabase().setMaterialColor(webMaterial, 192, 192, 192, 255)
	Call getUserMaterialDatabase().setMaterialCategories(webMaterial, Array("Sleeve material", "Shaft material", "Housing material", "Conducting material", "Coil winding material", "Brush material", "Segment material"))
	REDIM ArrayOfValues(0, 2)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= 1
	ArrayOfValues(0, 2)= 0
	Call getUserMaterialDatabase().setMagneticPermeability(webMaterial, ArrayOfValues, infoLinearIsotropicReal)
	REDIM ArrayOfValues(0, 1)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= webConductivity
	Call getUserMaterialDatabase().setElectricConductivity(webMaterial, ArrayOfValues, infoLinearIsotropicReal)
	REDIM ArrayOfValues(0, 1)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= 1
	Call getUserMaterialDatabase().setElectricPermittivity(webMaterial, ArrayOfValues, infoLinearIsotropicReal)
	REDIM ArrayOfValues(0, 1)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= 204
	Call getUserMaterialDatabase().setThermalConductivity(webMaterial, ArrayOfValues)
	REDIM ArrayOfValues(0, 1)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= 896
	Call getUserMaterialDatabase().setThermalSpecificHeatCapacity(webMaterial, ArrayOfValues)
	REDIM ArrayOfValues(0, 1)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= 2707
	Call getUserMaterialDatabase().setMassDensity(webMaterial, ArrayOfValues)
End If

If NOT getUserMaterialDatabase().isMaterialInDatabase(plateMaterial) Then
	Call getUserMaterialDatabase().newMaterial(plateMaterial)
	Call getUserMaterialDatabase().setMaterialColor(plateMaterial, 192, 192, 192, 255)
	Call getUserMaterialDatabase().setMaterialCategories(plateMaterial, Array("Sleeve material", "Shaft material", "Housing material", "Conducting material", "Coil winding material", "Brush material", "Segment material"))
	REDIM ArrayOfValues(0, 2)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= 1
	ArrayOfValues(0, 2)= 0
	Call getUserMaterialDatabase().setMagneticPermeability(plateMaterial, ArrayOfValues, infoLinearIsotropicReal)
	REDIM ArrayOfValues(0, 1)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= plateCondutivity
	Call getUserMaterialDatabase().setElectricConductivity(plateMaterial, ArrayOfValues, infoLinearIsotropicReal)
	REDIM ArrayOfValues(0, 1)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= 1
	Call getUserMaterialDatabase().setElectricPermittivity(plateMaterial, ArrayOfValues, infoLinearIsotropicReal)
	REDIM ArrayOfValues(0, 1)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= 204
	Call getUserMaterialDatabase().setThermalConductivity(plateMaterial, ArrayOfValues)
	REDIM ArrayOfValues(0, 1)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= 896
	Call getUserMaterialDatabase().setThermalSpecificHeatCapacity(plateMaterial, ArrayOfValues)
	REDIM ArrayOfValues(0, 1)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= 2707
	Call getUserMaterialDatabase().setMassDensity(plateMaterial, ArrayOfValues)
End If

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

' Rail and Plate motions

Call getDocument().makeMotionComponent(Array("Rail"))
Call getDocument().setMotionSourceType("Motion#1", infoVelocityDriven)
Call getDocument().setMotionType("Motion#1", infoLinear)
Call getDocument().setMotionLinearDirection("Motion#1", Array(0, 0, 1))
Call getDocument().setMotionPositionAtStartup("Motion#1", -motionLength/2.0)
' Call getDocument().setMotionSpeedAtStartup("Motion#1", speed)
Call getDocument().setMotionSpeedVsTime("Motion#1", Array(0), Array(speed))
Call getDocument().setMotionLinearDirection("Motion#1", Array(0, 0, 1))

Call getDocument().makeMotionComponent(Array("Plate1"))
Call getDocument().setMotionSourceType("Motion#2", infoVelocityDriven)
Call getDocument().setMotionType("Motion#2", infoLinear)
Call getDocument().setMotionLinearDirection("Motion#2", Array(0, 0, 1))
Call getDocument().setMotionPositionAtStartup("Motion#2", -motionLength/2.0)
' Call getDocument().setMotionSpeedAtStartup("Motion#2", speed)
Call getDocument().setMotionSpeedVsTime("Motion#2", Array(0), Array(speed))
Call getDocument().setMotionLinearDirection("Motion#2", Array(0, 0, 1))

If NOT(BUILD_WITH_SYMMETRY) Then
	Call getDocument().makeMotionComponent(Array("Plate2"))
	Call getDocument().setMotionSourceType("Motion#3", infoVelocityDriven)
	Call getDocument().setMotionType("Motion#3", infoLinear)
	Call getDocument().setMotionLinearDirection("Motion#3", Array(0, 0, 1))
	Call getDocument().setMotionPositionAtStartup("Motion#3", -motionLength/2.0)
	' Call getDocument().setMotionSpeedAtStartup("Motion#3", speed)
	Call getDocument().setMotionSpeedVsTime("Motion#3", Array(0), Array(speed))
	Call getDocument().setMotionLinearDirection("Motion#3", Array(0, 0, 1))
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

    if NOT(BUILD_WITH_SYMMETRY) Then
        Call view.getSlice().moveInAnArc(0, 0, 0, 1, 180.0)

        ReDim MagnetsB(numMagnets - 1)

        Call view.getSlice().moveInAnArc(Px, Py, axisX, axisY, 360.0 / numMagnets / 2.0 + wheelOffsetAngle*(n - 1))

        For i = 1 To numMagnets
            circleAngle = PI * 2.0 * (i - 1) / numMagnets 

            ' Circumferential vector
            x1 = Cos(wheelAngle)*Sin(circleAngle)
            y1 = -Sin(wheelAngle)*Sin(circleAngle)
            z1 = -Cos(circleAngle)

            ' Vector pointing outwards on magnet
            x2 = -Sin(wheelAngle + magnetAngle)*(Cos(circleAngle) + Sin(wheelAngle)*Sin(wheelAngle)*(1 - Cos(circleAngle))) - Cos(wheelAngle + magnetAngle)*Sin(wheelAngle)*Cos(wheelAngle)*(1 - Cos(circleAngle))
            y2 = -Sin(wheelAngle + magnetAngle)*Sin(wheelAngle)*Cos(wheelAngle)*(1 - Cos(circleAngle)) - Cos(wheelAngle + magnetAngle)*(Cos(circleAngle) + Cos(wheelAngle)*Cos(wheelAngle)*(1 - Cos(circleAngle)))
            z2 = -Sin(wheelAngle + magnetAngle)*Cos(wheelAngle)*Sin(circleAngle) + Cos(wheelAngle + magnetAngle)*Sin(wheelAngle)*Sin(circleAngle)

            magnetizationAngle = -(i - 1) * rollAngle + PI

            ' Components of magnetization vector
            x_hat = x1*Sin(magnetizationAngle) + x2*Cos(magnetizationAngle)
            y_hat = y1*Sin(magnetizationAngle) + y2*Cos(magnetizationAngle)
            z_hat = z1*Sin(magnetizationAngle) + z2*Cos(magnetizationAngle)

            direction = "[" & x_hat & "," & y_hat & "," & z_hat & "]"
            
            Call view.selectAll(infoSetSelection, Array(infoSliceSurface))

            Call view.makeComponentInAnArc(Px, Py, axisX, axisY, -360.0 / numMagnets, Array("MagnetB" & n & "#" & i), "Name=" & magnetMaterial & ";Type=Uniform;Direction=" & direction, infoMakeComponentUnionSurfaces Or infoMakeComponentRemoveVertices)

            Call getDocument().setMaxElementSize("MagnetB" & n & "#" & i, magnetResolution)
            Call getDocument().setMaxElementSize("MagnetB" & n & "#" & i & ",Face#4", magnetFaceResolution)

            Call view.getSlice().moveInAnArc(Px, Py, axisX, axisY, -360.0 / numMagnets)

            MagnetsB(i - 1) = "MagnetB" & n & "#" & i
        Next
        
        Call getDocument().shiftComponent(MagnetsB, offsetX, 0, 0, 1)

        Call view.getSlice().moveInAnArc(Px, Py, axisX, axisY, -360.0 / numMagnets / 2.0 - wheelOffsetAngle*(n - 1))

        Call view.getSlice().moveInAnArc(0, 0, 0, 1, 180.0)
    End If

    ' Magnet Motion

    Call getDocument().makeMotionComponent(MagnetsA)
    Call getDocument().setMotionSourceType("Motion#" & (n*symmetrySides + 2), infoVelocityDriven)
    Call getDocument().setMotionRotaryCenter("Motion#" & (n*symmetrySides + 2), Array(Px, Py, wheelsLength / 2.0 - outerRadius - (n - 1)*wheelOffsetZ))
    Call getDocument().setMotionRotaryAxis("Motion#" & (n*symmetrySides + 2), Array(axisX, axisY, 0))
    Call getDocument().setMotionPositionAtStartup("Motion#" & (n*symmetrySides + 2), 0)
    ' Call getDocument().setParameter("Motion#" & (n*symmetrySides + 2), "SpeedAtStartup", "-(%rotSpeed)", infoNumberParameter)
    Call getDocument().setParameter("Motion#" & (n*symmetrySides + 2), "SpeedVsTime", "[0%ms, -(%rotSpeed)]", infoArrayParameter)

    ' 2nd wheel of magnets motion
    If NOT(BUILD_WITH_SYMMETRY) Then
        Call getDocument().makeMotionComponent(MagnetsB)
        Call getDocument().setMotionSourceType("Motion#" & (n*symmetrySides + 3), infoVelocityDriven)
        Call getDocument().setMotionRotaryCenter("Motion#" & (n*symmetrySides + 3), Array(-Px, Py, wheelsLength / 2.0 - outerRadius - (n - 1)*wheelOffsetZ))
        Call getDocument().setMotionRotaryAxis("Motion#" & (n*symmetrySides + 3), Array(-axisX, axisY, 0))
        Call getDocument().setMotionPositionAtStartup("Motion#" & (n*symmetrySides + 3), 0)
        ' Call getDocument().setParameter("Motion#" & (n*symmetrySides + 3), "SpeedAtStartup", "%rotSpeed", infoNumberParameter)
        Call getDocument().setParameter("Motion#" & (n*symmetrySides + 3), "SpeedVsTime", "[0%ms, %rotSpeed]", infoArrayParameter)
    End If

    Call view.getSlice().moveInALine(-wheelOffsetZ)
Next

Call view.getSlice().moveInALine(-wheelsLength / 2.0 + outerRadius)

Call view.selectAll(infoSetSelection, Array(infoSliceLine))
Call view.deleteSelection()

Call view.getSlice().moveInALine(wheelOffsetZ * numWheels)


' Setup Simulation

Call getDocument().setTimeStepMethod(infoFixedIntervalTimeStep)
' Call getDocument().setFixedIntervalTimeSteps(0, solveStep*numSteps, solveStep)
' Call getDocument().deleteTimeStepMaximumDelta()
' Call getDocument().setAdaptiveTimeSteps(0, solveStep*numSteps, solveStep, solveStep * 4)
' Call getDocument().setTimeAdaptionTolerance(0.03)

Call getDocument().useHAdaption(useHAdaption)
Call getDocument().usePAdaption(usePAdaption)

Call getDocument().newPlanarSlice("SliceZ", Array(0, 0, 0), Array(0, 0, 1))
Call getDocument().newPlanarSlice("SliceX", Array(0, 0, 0), Array(1, 0, 0))
Call getDocument().newPlanarSlice("SliceY", Array(0, (Ay + By) / 2.0, 0), Array(0, 1, 0))

Dim text1

text1 = ""

If numSpeedSteps = 1 Then
	rps = (speed + slipSpeed) / (magneticCircumference)
    text1 = text1 & rps*2.0*PI & "%rad"
Else
    For i = 1 to numSpeedSteps
        slipSpeed = (i - 1) * ((maxSlipSpeed - minSlipSpeed) / (numSpeedSteps - 1)) + minSlipSpeed
        rps = (speed + slipSpeed) / (magneticCircumference)
        text1 = text1 & rps*2.0*PI & "%rad"
        If i <> numSpeedSteps Then
            text1 = text1 & ", "
        End If
    Next
End If

Call getDocument().setParameter("", "rotSpeed", text1, infoNumberParameter)
Call getDocument().setParameter("", "TimeSteps", "[0%ms, (1000.0/((%rotSpeed/(2.0*%Pi))*" & numMagnets & "*" & solveStepsPerMagnet & "))%ms, " & "(1000.0/((%rotSpeed/(2.0*%Pi))*" & numMagnets & "*" & solveStepsPerMagnet & ")*" & numSteps & ")%ms]", infoArrayParameter)

' Scale view to fit

Call getDocument().getView().setScaledToFit(True)

' Run Simulations

if runSimulation Then
	Call getDocument().solveTransient3DWithMotion()
End If