function cubeimg = find_cube(img, N)
% find rubiks cube in img and return cropped img
% N is dimension of rubiks cube
BW = zeros(size(img));
thresh = 0.8;
nchan = size(img,3);
for i = 1:nchan
    BW(:,:,i) = imbinarize(imcomplement(img(:,:,i)), thresh);
end
BW = (sum(BW,3) >= nchan);
%figure, imshow(BW)

[H,T,R] = hough(BW);
%figure, imshow(H,[],'XData',T,'YData',R,...
%            'InitialMagnification','fit');
%xlabel('\theta'), ylabel('\rho');
%axis on, axis normal, hold on;

% only find horizontal or vertical lines
H(:, [15:75,105:165]) = 0;

shift = 45;
Hshift = [flipud(H(:,end-shift+1:end)), H(:,1:end-shift)];
Tshift = T - shift;

P = houghpeaks(Hshift,2*(N+1),'threshold',ceil(0.3*max(H(:))), ...
    'NHoodSize', [101,91]);
%plot(x,y,'s','color','white');
theta = Tshift(P(:,2)); rho = R(P(:,1));
horz = zeros(2,0); vert = zeros(2,0);
for i = 1:length(theta)
    if -15 <= theta(i) && theta(i) <= 15
        vert(:,end+1) = [theta(i); rho(i)];
    else
        horz(:,end+1) = [theta(i); rho(i)];
    end
end
top = floor(min(sign(horz(1,:)) .* horz(2,:)));
down = floor(max(sign(horz(1,:)) .* horz(2,:)));
left = floor(min(vert(2,:)));
right = floor(max(vert(2,:)));

cubeimg = img(top:down, left:right, :);

% lines = houghlines(BW,T,R,P,'FillGap',30,'MinLength',100);
% 
% figure, imshow(img), hold on
% for k = 1:length(lines)
%    xy = [lines(k).point1; lines(k).point2];
%    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 
%    % Plot beginnings and ends of lines
%    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% end
