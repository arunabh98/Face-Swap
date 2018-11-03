%  An example how to use landmarks points
%  The below codes are not optimized. It is straightforward for easy
%  understanding.
%  Copyright 2014 by Caroline Pacheco do E.Silva
%  If you have any problem, please feel free to contact Caroline Pacheco do E.Silva.
%  lolyne.pacheco@gmail.com
%
%  If the algorithm is tested with other databases,  you may need to change
%  some parameters (See the file readme)
%% 

clc
clear all

% read the input image
I = imread('../Images/face4.jpg');
%I = imresize(I, [224,224]);

[imgFace, LeftEye, RightEye, Mouth] = detectFacialRegions(I);

% config landmarks to Eyes and Mouth (4 and 5)
landconf = 5;


%% landmarks the eyes
imgLeftEye = (imgFace(LeftEye(1,2):LeftEye(1,2)+LeftEye(1,4),LeftEye(1,1):LeftEye(1,1)+LeftEye(1,3),:));
[landLeftEye, leftEyeCont] = eyesProcessing(imgLeftEye,landconf);

imgRightEye = (imgFace(RightEye(1,2):RightEye(1,2)+RightEye(1,4),RightEye(1,1):RightEye(1,1)+RightEye(1,3),:));
[landRightEye, rightEyeCont] = eyesProcessing(imgRightEye,landconf);

% landmarks the mouth
imgMouth = (imgFace(Mouth(1,2):Mouth(1,2)+Mouth(1,4),Mouth(1,1):Mouth(1,1)+Mouth(1,3),:));
[landMouth, MouthCont] = mouthProcessing(imgMouth,landconf);


%% shows (eyes and mouth)

imshow(imgFace,'InitialMagnification',50); hold on;
[left_eye_x, left_eye_y]=showsLandmarks(landLeftEye,leftEyeCont,LeftEye,landconf);
[right_eye_x, right_eye_y]=showsLandmarks(landRightEye,rightEyeCont,RightEye,landconf);
[mouth_x, mouth_y]=showsLandmarks(landMouth,MouthCont,Mouth,landconf);
