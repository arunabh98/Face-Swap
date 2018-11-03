function output_img  = Affine_fn(I_d, I_s)

faceDetector = vision.CascadeObjectDetector();

%%destination face
% I_d = imread('../Images/face2.jpg');
bbox_d = step(faceDetector, I_d);
[left_eye_d,right_eye_d, Face_d]= my_detect_landmark(I_d);
theta_d = asin((left_eye_d(2) - right_eye_d(2))/(right_eye_d(1) - left_eye_d(1)));

 
%%source face
% I_s = imread('../Images/face.jpg');
bbox_s = step(faceDetector, I_s);
[left_eye_s,right_eye_s, Face_s]= my_detect_landmark(I_s);
theta_s = asin((left_eye_s(2) - right_eye_s(2))/(right_eye_s(1) - left_eye_s(1)));
 
    dtheta = theta_s - theta_d;
    ds = sqrt(sum((left_eye_s - right_eye_s).^2)) / sqrt(sum((left_eye_d - right_eye_d).^2));

    Affine_mat = [ds*cos(dtheta) -ds*sin(dtheta) 0; ds*sin(dtheta) ds*cos(dtheta) 0; 0 0 1];
    tform = maketform('affine', Affine_mat );
    
    face_warp = imtransform(imcrop(I_d, bbox_d), tform);
    [left_eye_w,right_eye_w, Face_w, Img_Face_w]= my_detect_landmark(face_warp);
    d = size(Img_Face_w, 2) - left_eye_w(2);
    output_img = uint8(zeros(size(I_s)));
    
    zero_xy=[Face_s(1)+ Face_w(1), Face_s(2) + Face_w(2)];
    output_img(zero_xy(1):zero_xy(1)+size(face_warp, 1) - 1,zero_xy(2):zero_xy(2)+size(face_warp, 2) - 1,:)= face_warp;
    figure; imshow(mat2gray(output_img));