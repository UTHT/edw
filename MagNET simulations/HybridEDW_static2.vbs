const PI = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067

' Materials

webMaterial = "Aluminium 6061-T6"
webConductivity = 24940400
plateMaterial = "Aluminium 6101-T61"
plateCondutivity = 24940400
magnetMaterial = "N50"

' Track dimensions
const webWidth = 127 'length of track
const webThickness = 4
const plateWidth = 127 'length of track
const plateThickness = 12.7

const BUILD_WITH_SYMMETRY = False	' Build only half of the track and one wheel, with symmetry conditions
const DO_NOT_BUILD = False ' do not build the other wheel with no symmetry conditions
const runSimulation = False			' Automatically run simulation

' EDW dimensions
numMagnets =5*4				' Number of magnets per wheel
rollAngle = 90.0 * PI / 180.0		' Change in angle from the face of the magnet (rad)
magnetWidth = 15					' Width of magnets
levitationHeight = 10				' Height from lowest point of magnets to conducting plate
railClearance = 6					' Clearance from magnets to rail
wheelAngle = 45.0 * PI / 180.0   	' Tilt of entire wheel assembly towards rail (from horizontal) (rad)
magnetAngle = 45 * PI / 180.0  	' Tilt of individual magnets outwards (from pointing downwards) (rad)
offsetX = 0.0						' Offset of both wheels laterally to test for guidance force (only works when simulating without symmetry)

numWheels = 1
spaceBetweenWheels =100

If BUILD_WITH_SYMMETRY Then
    offsetX = 0.0
End If

'---------------------NEW radius RATIO CODE-------------------
ratio = 0.82 'ri ro ratio
outerRadius = 67*Cos(wheelAngle) ' radius from the centre axis to the outer most point of the wheel
innerRadius = 50*Cos(wheelAngle)  ' radius from the centre axis to the smallest circle of the wheel
magnetDepth = (outerRadius - innerRadius)/Cos(wheelAngle) 'difference between the inner and outer radius

magneticCircumference = outerRadius*PI*2.0/1000 		' Magnetic circumference of wheel (important for accurate slip speeds)
'------------------------END OF NEW RADIUS CODE-------------------------

wheelsLength = 3*(outerRadius * 2.0 * numWheels + spaceBetweenWheels * (numWheels - 1))
wheelOffsetZ = outerRadius * 2.0 + spaceBetweenWheels
'wheelOffsetAngle = wheelOffsetZ/magneticCircumference*PI*2.0
wheelOffsetAngle = 0
offsetZ = -wheelsLength/2 + outerRadius
' Air boundaries

airYCut = 0.0
airXCut = 0.0
airYMin = -10.0
airZClearance = 40.0
airZ = wheelsLength / 2.0 + airZClearance

' Mesh resolutions
airRailBoundary = 1.5 '2 3
airResolution = 3 '3
aluminiumResolution = 5
magnetResolution = 1.5
railSurfaceResolution = 5
plateSurfaceResolution = 5
magnetFaceResolution = 0.5 '0.5 '1
useHAdaption = False
usePAdaption = False

' Magnet geometry
'------------------------------NEW MODIFIED GEOMETRY CODE--------------------
Bx = -railClearance - webThickness/2.0
Ay = levitationHeight + 2.0*(innerRadius + magnetDepth*Cos(wheelAngle))*Sin(wheelAngle) + plateThickness
Ax = Bx - magnetWidth*Cos(wheelAngle + magnetAngle)
By = Ay + magnetWidth*Sin(wheelAngle + magnetAngle)
Cx = Bx - magnetDepth*Sin(wheelAngle + magnetAngle)
Cy = By + magnetDepth*Cos(wheelAngle + magnetAngle)
Dx = Ax - magnetDepth*Sin(wheelAngle + magnetAngle)
Dy = Ay + magnetDepth*Cos(wheelAngle + magnetAngle)

magnetMidX = (Ax + Bx + Cx + Dx) / 4.0
magnetMidY = (Ay + By + Cy + Dy) / 4.0

Px = -magnetDepth*Cos(wheelAngle + magnetAngle) - (innerRadius + magnetDepth*Cos(wheelAngle))*Cos(wheelAngle) - railClearance - webThickness/2.0 ' center point x-dir of wheel
Py = (innerRadius + magnetDepth*Cos(wheelAngle))*Sin(wheelAngle) + levitationHeight + plateThickness 'center point y-dir of wheel

axisX = -Sin(wheelAngle)
axisY = Cos(wheelAngle)

magnetLevitationFaceX = -Px + innerRadius*Cos(wheelAngle) + magnetWidth/2.0*Cos(wheelAngle - magnetAngle)
'-------------------------------END OF MODIFIED GEOMETRY CODE----------------------------

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

' Web/rail

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

'--------------------------NEW CODE FOR MAGNETIZATION DIRECTION---------------------
    j = 0 ' counter in the if statement
    k = 0 ' counter in the if statement
    ReDim MagnetsA(numMagnets - 1)


    Call view.getSlice().moveInAnArc(Px, Py, axisX, axisY, -360.0 / numMagnets / 2.0 - wheelOffsetAngle*( 1))

    For i = 1 To numMagnets

        circleAngle2 = -PI*2.0*(i - 1) / numMagnets ' circle divided into equal angles depending on the number of magnets

        'determining magnetization direction
        'starting with a single arrow on the first magnet pointing outwards of the circle, find the vectors pointing out for each magnet by rotation around y-axis
        A = Sin(magnetAngle)*Cos(circleAngle2) 'xhat
        B = Sin(magnetAngle)*Sin(circleAngle2) 'vertical angle zhat
        C = -Cos(magnetAngle) ' yhat


      if (-1)^i > 0 Then ' for globally even number magnets rotate the vector 90 degrees (i.e. the rollangle) from its current position
       k=k+1 ' counter
       x_hat2 = A*Cos(rollangle) - B*Sin(rollangle) '
       z_hat2 = B*Cos(rollangle) + A*Sin(rollangle)

       if (-1)^k < 0 Then 'for odd number magnets within the globally even number magnets, have the vector direction
           x_hat2 = x_hat2
           z_hat2 = z_hat2
           C=0
       else ' for even number magnets within the globally even number magnets, vector direction is in the opposite direction (pointing opposite direction)
           x_hat2 = -x_hat2
           z_hat2 = -z_hat2
           C=0
       end If
       else ' for globally odd number magnets do not rotate the vector 90 degrees
        j=j+1
          if (-1)^j > 0 Then ' for even number magnets of the globally odd number magnets, vector direction is pointing into the wheel
           x_hat2 = -A
           z_hat2 = -B
           C=-C
           else ' for odd number magnets of globally odd number magnets, vector direction is still pointing out of the wheel
           x_hat2 = A
           z_hat2 = B
           end If
      end If
   ' final vector of a magnet in the wheel by rotating by the wheelAngle
      xh_new = Cos(-wheelAngle)*x_hat2 + C*Sin(-wheelAngle)
      yh_new = -Sin(-wheelAngle)*x_hat2 + C*Cos(-wheelAngle)
      zh_new = z_hat2 ' vertical axis
'--------------------END OF CODE FOR MAGNETIZATION DIRECTION---------------------
        direction = "[" & xh_new & "," & yh_new & "," & zh_new & "]"

        Call view.selectAll(infoSetSelection, Array(infoSliceSurface))

        Call view.makeComponentInAnArc(Px, Py, axisX, axisY, 360.0 / numMagnets, Array("MagnetA" & n & "#" & i), "Name=" & magnetMaterial & ";Type=Uniform;Direction=" & direction, infoMakeComponentUnionSurfaces Or infoMakeComponentRemoveVertices)

        Call getDocument().setMaxElementSize("MagnetA" & n & "#" & i, magnetResolution)
        Call getDocument().setMaxElementSize("MagnetA" & n & "#" & i & ",Face#4", magnetFaceResolution)

        Call view.getSlice().moveInAnArc(Px, Py, axisX, axisY, 360.0 / numMagnets)

        MagnetsA(i - 1) = "MagnetA" & n & "#" & i
    Next

    Call getDocument().shiftComponent(MagnetsA, offsetX, 0, 0, 1)


    Call view.getSlice().moveInAnArc(Px, Py, axisX, axisY, 360.0 / numMagnets / 2.0 + wheelOffsetAngle*( 1))

if NOT(DO_NOT_BUILD) Then
    if NOT(BUILD_WITH_SYMMETRY) Then
        Call view.getSlice().moveInAnArc(0, 0, 0, 1, 180.0)

        ReDim MagnetsB(numMagnets - 1)

        Call view.getSlice().moveInAnArc(Px, Py, axisX, axisY, 360.0 / numMagnets / 2.0 + wheelOffsetAngle*( 1))

  '---------------------NEW CODE for MAGNETIZATION direction--------------------------
        j = 0 ' counter for if statement
        k = 0 ' counter for if statement
        For ii = 1 To numMagnets
        circleAngle3 = -PI*2.0*(ii - 1) / numMagnets ' circle divided into equal angles depending on the number of magnets

        'determining magnetization direction
        'starting with a single arrow on the first magnet pointing outwards of the circle, find the vectors pointing out for each magnet by rotation around y-axis

        A = -Cos(circleAngle3)*Sin(magnetAngle) 'xcoordinate
        C = -Cos(magnetAngle) 'y aka the vertical axis
        B = Sin(circleAngle3)*Sin(magnetAngle) 'z

        if (-1)^ii > 0 Then ' for globally even number magnets rotate the vector 90 degrees (i.e. the rollangle) from its current position
        k=k+1 ' counter
        x_hat2 = A*Cos(rollangle) - B*Sin(rollangle) '
        z_hat2 = B*Cos(rollangle) + A*Sin(rollangle)

        if (-1)^k< 0 Then 'for odd number magnets within the globally even number magnets, have the vector direction
            x_hat2 = x_hat2
            z_hat2 = z_hat2
            C=0
          else ' for even number magnets within the globally even number magnets, vector direction is in the opposite direction (pointing opposite direction)
           x_hat2 = -x_hat2
           z_hat2 = -z_hat2
           C=0
        end If
      else ' for globally odd number magnets do not rotate the vector 90 degrees
        j=j+1
         if (-1)^j < 0 Then ' for even number magnets of the globally odd number magnets, vector direction is pointing into the wheel
           x_hat2 = -A
           z_hat2 = -B
           C=-C
          else ' for odd number magnets of globally odd number magnets, vector direction is still pointing out of the wheel
           x_hat2 = A
           z_hat2 = B
          end If
        end If
   ' final vector of a magnet in the wheel by rotating by the wheelAngle

      xh_new = x_hat2*cos(wheelAngle) + C*sin(wheelAngle)
      yh_new = -x_hat2*sin(wheelAngle) + C*cos(wheelAngle)
      zh_new = z_hat2
      '-------------------END OF NEW CODE FOR MAGNETIZATION direction---------------------
            direction = "[" & xh_new & "," & yh_new & "," & zh_new & "]"

            Call view.selectAll(infoSetSelection, Array(infoSliceSurface))

            Call view.makeComponentInAnArc(Px, Py, axisX, axisY, -360.0 / numMagnets, Array("MagnetB" & n & "#" & ii), "Name=" & magnetMaterial & ";Type=Uniform;Direction=" & direction, infoMakeComponentUnionSurfaces Or infoMakeComponentRemoveVertices)

            Call getDocument().setMaxElementSize("MagnetB" & n & "#" & ii, magnetResolution)
            Call getDocument().setMaxElementSize("MagnetB" & n & "#" & ii & ",Face#4", magnetFaceResolution)

            Call view.getSlice().moveInAnArc(Px, Py, axisX, axisY, -360.0 / numMagnets)

            MagnetsB(ii - 1) = "MagnetB" & n & "#" & ii
        Next

        Call getDocument().shiftComponent(MagnetsB, offsetX, 0, 0, 1)

        Call view.getSlice().moveInAnArc(Px, Py, axisX, axisY, -360.0 / numMagnets / 2.0 - wheelOffsetAngle*( 1))

        Call view.getSlice().moveInAnArc(0, 0, 0, 1, 180.0)
    End If
end if
    Call view.getSlice().moveInALine(-wheelOffsetZ)
Next
Call view.getSlice().moveInALine(-wheelsLength / 2.0 + outerRadius)

Call view.selectAll(infoSetSelection, Array(infoSliceLine))
Call view.deleteSelection()

Call view.getSlice().moveInALine(wheelOffsetZ * numWheels)

' Scale view to fit

Call getDocument().getView().setScaledToFit(True)

'Call getDocument().getView().selectObject("Rail", infoSetSelection)
'Call getDocument().getView().deleteSelection()
'Call getDocument().getView().selectObject("Plate1", infoSetSelection)
'Call getDocument().getView().deleteSelection()
'Call getDocument().getView().selectObject("Plate2", infoSetSelection)
'Call getDocument().getView().deleteSelection()

' Run Simulations


Call getDocument().solveStatic3d()
'For n = 1 To numWheels
'For i = 1 To numMagnets - 1
'  Call getDocument().getSolution().setComponentForceInterfaceType(1, "MagnetA" & n & "#" & i, "MagnetA" & n & "#" & i+1, infoComponentForceAssembled)
  'Call getDocument().getSolution().setComponentForceInterfaceType(1, "MagnetB" & n & "#" & i, "MagnetB" & n & "#" & i+1, infoComponentForceAssembled)

'Next
'Next
'  Call getGlobalResultsView().exportData(infoDataComponentForce, "C:\Users\BC\Desktop\enclosuremagnetforce.csv", infoDataFormatLocaleListSeparatorDelimitedLocaleDecimal)
