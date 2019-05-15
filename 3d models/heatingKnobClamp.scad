knobDiameter = 4.3;
knobRadius = knobDiameter/2;
knobInnerDiameter = 3.60;
knobInnerRadius = knobInnerDiameter/2;
knobDiameterEnd = 3.38;
knobRadiusEnd = knobDiameterEnd/2;
targetDepth=knobRadius-knobInnerRadius;


//insetSelfRadius = (345/200)*knobRadius;

insetSelfRadius = 1.45;

//insetFromKnobRadius = (512/200)*knobRadius;
insetFromKnobRadius = knobRadius+insetSelfRadius -targetDepth ;


knobDepth=4.15;
knobIntialInsetDepth = 0.6;
knobInitialInsetRadius=knobInnerRadius;


$fn = 150;

chamferSlack = 0.1;

gripperDepth = 2;
gripperEndCapDepth = 0.2;
servoPieceDiameter = 3.2;
servoCloverRadius =0.55;
servoClampDepth = 0.6;

module HeatingKnob(knobRadius, knobRadiusEnd, knobInitialInsetRadius,insetFromKnobRadius){
        
    difference(){
            union(){
        rotate([0,90])cylinder(r2=knobRadius, r1=knobRadiusEnd, h=knobDepth-knobIntialInsetDepth);
            translate([knobDepth-knobIntialInsetDepth,0,0])rotate([0,90])cylinder(r1=knobRadius, r2=knobInitialInsetRadius, h=knobIntialInsetDepth);
            }
            
        union(){
            insetCount = 6;
            increment = 360/insetCount;
            for(insetAngle = [0 : increment : 360]){
                
                z =  sin(insetAngle)*insetFromKnobRadius;
                y =  cos(insetAngle)*insetFromKnobRadius;
                translate([-chamferSlack,y,z])rotate([0,90])cylinder(r=insetSelfRadius, h=knobDepth+chamferSlack*2);

            };
        }
    }
    
}

//difference(){
gripperRadius = knobRadius*1.08;
sliderWidth = 0.1;
sliderRadius = 0.25;
module MainClamp(){

color([0.3,0.1,1])difference(){
    
    ;
    

    difference(){
        union(){
            
            //Big ring which is most of the clamp:
            translate([knobDepth-gripperDepth,0,0])rotate([0,90])cylinder(r=gripperRadius, h=gripperDepth+servoClampDepth);
            //Outer ring for clamp rotation mount
            
            
             //translate([knobDepth-gripperDepth,0,0])rotate([0,90])cylinder(r=gripperRadius+sliderRadius, h=sliderWidth);
            //Second outer ring
            translate([knobDepth+servoClampDepth,0,0])rotate([0,90])cylinder(r=gripperRadius+sliderRadius, h=sliderWidth);
            
        }
        cloverCount = 6;
        increment = 360/cloverCount;
        for(insetAngle = [0 : increment : 360]){
            z =  sin(insetAngle)* (servoPieceDiameter/2 - (servoCloverRadius/2));
            y = cos(insetAngle)*(servoPieceDiameter/2 - (servoCloverRadius/2));
            translate([knobDepth+gripperEndCapDepth,y,z])rotate([0,90])cylinder(r=(servoCloverRadius/2), h=servoClampDepth);
        }
        translate([knobDepth+gripperEndCapDepth,0,0])rotate([0,90])cylinder(r=knobRadius*0.6, h=servoClampDepth);
        
    }
    HeatingKnob(knobRadius, knobRadius, knobRadius, insetFromKnobRadius);

}};
//MainClamp();
/*
translate([2.5,-5,-5])cube([4,10,10]);
}*/

targetGrabWidth = 3.5;
outset=1;
tubingRadius = 2.8/2;

//Create environment:
/*HeatingKnob(knobRadius, knobRadiusEnd, knobInitialInsetRadius,insetFromKnobRadius);


rotate([0,-90])cylinder(r=tubingRadius,h=7.35-knobDepth);


translate([-7.35+knobDepth+tubingRadius,0.5*targetGrabWidth,0])rotate([0,-90,90])cylinder(r=2.8/2,h=targetGrabWidth);
*/

//Engine:

engineHolderWidth = gripperRadius*2.1;
engineHolderDepth = 2;
engineHolderHeight = 0.75;
engineHolderStart =7.6
;

module EngineHolder(){
    difference(){
    
    engineHolderHoleRadius = 0.52/2.0;
        
    translate([engineHolderStart,-engineHolderWidth*0.5,54.50/10 - 4.4 ])cube([1,engineHolderWidth,engineHolderHeight]);

    engineHolderMountingHoleStart = 0.5+engineHolderHoleRadius*1.5;
    translate([engineHolderStart+1.5-engineHolderDepth,-engineHolderMountingHoleStart, 1.45-engineHolderHoleRadius ])cube([engineHolderDepth,engineHolderMountingHoleStart*2,engineHolderHoleRadius*2]);
        
    translate([engineHolderStart+1.5,engineHolderMountingHoleStart, 1.45 ])rotate([0,-90,0])cylinder(r=engineHolderHoleRadius,h=engineHolderDepth);
    translate([engineHolderStart+1.5,-engineHolderMountingHoleStart, 1.45 ])rotate([0,-90,0])cylinder(r=engineHolderHoleRadius,h=engineHolderDepth);
        }
}

module MG995(){
    
    $fn = 30;
    //MG995 SCAD module by Buys de Barbanson
    translate([0,-19.90/2,0])cube([40.40,19.90,37.50]); // height excludes thing on top

    //Top plate with mounting holes:
    mountPlateZ = 29.0-6;
    difference(){
        translate([0,-19.90/2,mountPlateZ])translate([-7,0,6])cube([54.50,19.90,2.5]);
        //Mounting holes:


        distanceBetweenHolesWidth = 10;
        holeRad = 5.2/2.0;
        distanceBetweenHolesLength =48.6; //44.5+2*holeRad;//48;
        xStart = -4.5;
        translate([xStart,distanceBetweenHolesWidth/2,mountPlateZ])cylinder(r=holeRad,h=10);
        translate([xStart,-distanceBetweenHolesWidth/2,mountPlateZ])cylinder(r=holeRad,h=10);
        translate([xStart+distanceBetweenHolesLength,distanceBetweenHolesWidth/2,mountPlateZ])cylinder(r=holeRad,h=10);
        translate([xStart+distanceBetweenHolesLength,-distanceBetweenHolesWidth/2,mountPlateZ])cylinder(r=holeRad,h=10);
    }

    mainAxleRadius = 6.0/2;
    mainAxleDistanceToEnd = 10;
    translate([mainAxleDistanceToEnd,0,41])cylinder(r=mainAxleRadius, h=4);
    translate([mainAxleDistanceToEnd,0,36.5+3])cylinder(r=13/2, h=1.5);
    translate([mainAxleDistanceToEnd,0,36.5])cylinder(r=19/2, h=3);
};



// ** ENGINE MOUNT **//

//Create clamps:
clampThickness = 0.22;
nearPipePoint = [-7.35+knobDepth+2*tubingRadius,0.5*targetGrabWidth-0.5*clampThickness - 1*clampThickness ,-(tubingRadius+clampThickness)];
outsetPipePoint = [-7.35+knobDepth+2*tubingRadius,0.5*targetGrabWidth-0.5*clampThickness - 2*clampThickness +  outset ,-(tubingRadius+clampThickness)];

module ModuleJoinRing(){
    
    
    motorMountCylinderHeight = 0.2;
    boltRadius = 0.2;
    r = gripperRadius+1.5;
    r2 = gripperRadius+1.5 - boltRadius*2;
    difference(){
    translate([knobDepth+servoClampDepth-motorMountCylinderHeight-0.01,0,0])rotate([0,90])cylinder(r=r, h=motorMountCylinderHeight);
     boltCount = 20;
        increment = 360/boltCount;
        for(insetAngle = [0 : increment : 360]){
            z =  sin(insetAngle)* r2;
            y = cos(insetAngle)*r2;
            translate([knobDepth+gripperEndCapDepth,y,z])rotate([0,90])cylinder(r=(servoCloverRadius/2), h=servoClampDepth);
        }
    }
}

// Holder of main tube:
overLen = knobDepth*0.40;

module TubeMount(){
        translate([-7.35+knobDepth+tubingRadius,0.5*targetGrabWidth-0.5*clampThickness,0])rotate([0,-90,90])cylinder(r=tubingRadius + clampThickness,h=clampThickness);

    //Vertical plate
translate([-7.35+knobDepth+2*tubingRadius,0.5*targetGrabWidth-0.5*clampThickness - clampThickness,-(tubingRadius+clampThickness)])cube([clampThickness,outset,2*(tubingRadius+clampThickness)]);

// Stands from the pipe:
translate([-7.35+knobDepth+1*tubingRadius,0.5*targetGrabWidth-0.5*clampThickness - clampThickness,-(tubingRadius+clampThickness)])cube([tubingRadius+clampThickness,clampThickness,clampThickness]);
translate([-7.35+knobDepth+1*tubingRadius,0.5*targetGrabWidth-0.5*clampThickness - clampThickness,(tubingRadius)])cube([tubingRadius+clampThickness,clampThickness,clampThickness]);

// Stand heading over the knob:
translate([-7.35+knobDepth+2*tubingRadius,0.5*targetGrabWidth-0.5*clampThickness - 2*clampThickness +  outset ,-(tubingRadius+clampThickness)])cube([knobDepth,clampThickness,clampThickness]);
translate([-7.35+knobDepth+2*tubingRadius,0.5*targetGrabWidth-0.5*clampThickness - 2*clampThickness +  outset ,(tubingRadius)])cube([knobDepth,clampThickness,clampThickness]);

}

clampTubeThickNess = gripperRadius+0.6 - gripperRadius + 0.02;
tieWrapWidth = 0.3;


hh= 1.5;
slack = 0.05;
xOffset = -0.8;

extraClampShavingLen = 0.48;

difference(){
    union(){
        difference(){
        translate([xOffset,0,-hh*0.5])cylinder(h=hh,r=gripperRadius+clampTubeThickNess);
        translate([0.48+xOffset,-gripperRadius*2,-gripperRadius*2])cube([80,gripperRadius*4,gripperRadius*4]);
        }
        
        translate([xOffset+0.48-extraClampShavingLen,-gripperRadius-clampTubeThickNess,-hh*0.5])cube([abs(xOffset)+extraClampShavingLen,clampTubeThickNess,hh]);
        
          
        translate([xOffset+0.48-extraClampShavingLen,gripperRadius,-hh*0.5])cube([abs(xOffset)+extraClampShavingLen,clampTubeThickNess,hh]);
        
    }
    
    translate([xOffset+0.48-extraClampShavingLen,-gripperRadius,-hh*0.5])cube([abs(xOffset)+extraClampShavingLen,clampTubeThickNess,hh]);
    translate([xOffset+0.48-extraClampShavingLen,gripperRadius-clampTubeThickNess,-hh*0.5])cube([abs(xOffset)+extraClampShavingLen,clampTubeThickNess,hh]);
    
    
    translate([xOffset,0,-hh*0.5-0.25])cylinder(h=hh+0.5,r=gripperRadius);
    

    
    translate([-0.15,-40,-slack*0.5-0.31])cube([slack+clampTubeThickNess*2,80,clampTubeThickNess+slack]);
    
    translate([0.15,-gripperRadius-0.5*clampTubeThickNess,-10])cylinder(h=30,r=0.15);
    
        translate([0.15,gripperRadius+0.5*clampTubeThickNess,-10])cylinder(h=30,r=0.15);
}   




if(0){
color([1,1,0])union(){


    //TubeMount();
    //mirror([0,1,0])TubeMount();

    
    difference(){
        union(){
            ModuleJoinRing();
        
        translate([knobDepth-gripperDepth-overLen,0,0])rotate([0,90])cylinder(r=gripperRadius+0.6, h=overLen+gripperDepth+servoClampDepth-0.01);
        }
            translate([knobDepth-gripperDepth-overLen-1,0,0])rotate([0,90])cylinder(r=gripperRadius+ 0.03, h=gripperDepth+servoClampDepth+overLen+1);
    }
    
    difference(){
        translate([knobDepth-gripperDepth-overLen-clampTubeThickNess,gripperRadius,-clampTubeThickNess*0.5])cube([clampTubeThickNess*2,clampTubeThickNess,clampTubeThickNess]);
        translate([knobDepth-gripperDepth-overLen-clampTubeThickNess+0.15,gripperRadius+0.5*clampTubeThickNess-tieWrapWidth*0.5,-clampTubeThickNess*0.5 - 0.1])cube([tieWrapWidth,tieWrapWidth,clampTubeThickNess*2]);
    };
    translate([0,-2*gripperRadius-clampTubeThickNess,0])difference(){
        translate([knobDepth-gripperDepth-overLen-clampTubeThickNess,gripperRadius,-clampTubeThickNess*0.5])cube([clampTubeThickNess*2,clampTubeThickNess,clampTubeThickNess]);
        translate([knobDepth-gripperDepth-overLen-clampTubeThickNess+0.15,gripperRadius+0.5*clampTubeThickNess-tieWrapWidth*0.5,-clampTubeThickNess*0.5 - 0.1])cube([tieWrapWidth,tieWrapWidth,clampTubeThickNess*2]);
    }

}}