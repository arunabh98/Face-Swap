clc
clear all

source = imread('../Images/face2.jpg');
target = imread('../Images/face.jpg');

% im_source = imresize(source,[size(target,1),size(target,2)]);
im_source = Affine_fn(source,target);

% creating a mask 
imshow(im_source, []);
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

im_source = double(im_source);
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
    
    imglapl = conv2(im_source(:,:,i),laplacian_mask, 'same'); 
    
    %making count 0 again as to loop over the image under mask again
    count =0; 
    
    for k=1:size(look_up,1)
        for l=1:size(look_up,2)
            if (im_mask(k,l)==1)
                count = count +1; 
                A(count,count) = 4;
    %checking for boundaries
                
               
                
                %for the left 
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
                
                %for the right 
                if(im_mask(k+1,l) == 0)
                   b(count) = b(count) + im_target(k+1,l,i);
                else
                    A(count,look_up(k+1,l)) = -1;
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
figure; 

im_out = uint8(im_out);
imshow(im_out,[]); 

       
    





