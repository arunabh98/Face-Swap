source = imread('../Images/source.png');
target = imread('../Images/target.png');

% source = imread('../Images/face.jpg');
% target = imread('../Images/face2.jpg');

% im_source = Affine_fn(source,target);

% im_source = imresize(source,[size(target,1),size(target,2)]);
imshow(source,[]);
axis on; 
set(gcf,'Position',get(0,'Screensize')); 
message = sprintf('left click and hold to draw'); 
uiwait(msgbox(message)); 
h = imfreehand(); 
im_mask = h.createMask(); 
figure; 
imshow(im_mask,[]); 

target = double(target);
source = double(source);

im_target = target;  

im_out = im_target; 

n = size(find(im_mask==1),1);  %pixels under mask 

laplacian_mask = [0 1 0;1 -4 1;0 1 0];

look_up = zeros(size(im_mask));

count = 0;
for i=1:size(look_up, 1)
    for j=1:size(look_up, 2)
        if (im_mask(i,j) == 1)
            count = count +1;
            look_up(i,j) = count;
        end
    end
end


for i = 1:3 
    A = spalloc(n, n, n*5); % sparse implementation 
    b = zeros(n, 1);
    
    % taking only central part of the convolved image
    
    
    grad_x = [-1 1];
    grad_y = [-1;1];
    
    g_x_target = conv2(im_target(:,:,i), grad_x, 'same');
    g_y_target = conv2(im_target(:,:,i), grad_y, 'same');    
    g_mag_target = sqrt(g_x_target.^2 + g_y_target.^2);
    
    g_x_source = conv2(im_source(:,:,i), grad_x, 'same');
    g_y_source = conv2(im_source(:,:,i), grad_y, 'same');    
    g_mag_source = sqrt(g_x_source.^2 + g_y_source.^2);
    
    g_mag_target = g_mag_target(:);
    g_mag_source = g_mag_source(:);
    
    g_x_final = g_x_source(:);
    g_y_final = g_y_source(:);
    
    g_x_final(abs(g_mag_target)>abs(g_mag_source)) = g_x_target(g_mag_target>g_mag_source);
    g_y_final(abs(g_mag_target)>abs(g_mag_source)) = g_y_target(g_mag_target>g_mag_source);
    
    g_x_final = reshape(g_x_final,size(im_source,1),size(im_source,2));
    g_y_final = reshape(g_y_final,size(im_source,1),size(im_source,2));
    
    lap=conv2(g_x_final,grad_x,'same');
    imglapl = lap + conv2(g_y_final,grad_y,'same');
    %making count 0 again as to loop over the image under mask again
    count =0; 
    
    for k=1:size(look_up,1)
        for l=1:size(look_up,2)
            if (im_mask(k,l)==1)
                count = count +1; 
                A(count,count) = 4;
    %checking for boundaries
                
               
                %for the left 
                if(im_mask(k+1,l) == 0)
                   b(count) = b(count) + im_target(k+1,l,i);
                else
                    A(count,look_up(k+1,l)) = -1;
                end
                 
                %for the right 
                if(im_mask(k-1,l) == 0)
                   b(count) = b(count) + im_target(k-1,l,i);
                else
                    A(count,look_up(k-1,l)) = -1;
                end
                
                 %for the top 
                if(im_mask(k,l+1) == 0)
                   b(count) = b(count) + im_target(k,l+1,i);
                else
                    A(count,look_up(k,l+1)) = -1;
                end
                
                 % for the bottom
                if(im_mask(k,l-1) == 0)
                   b(count) = b(count) + im_target(k,l-1,i);
                else
                    A(count,look_up(k,l-1)) = -1;
                end
                
                
                b(count) = b(count) -imglapl(k,l); 
            end
        end
    end
    
   x = A\b; 
  
   for k = 1:length(x)
       [u,v] = find(look_up == k); 
       im_out(u,v,i) = x(k); 
   end
   
  
end
im_out = uint8(im_out); 
imshow(im_out,[]); 

       
    





