function ret = qtransform( qt, q )


ret = zeros(1,4);

ret(1) = q(1)*qt(1) -  q(2)*qt(2) -  q(3)*qt(3) -  q(4)*qt(4);%a
ret(2) = q(1)*qt(2) +  q(2)*qt(1) +  q(3)*qt(4) -  q(4)*qt(3);%x
ret(3) = q(1)*qt(3) -  q(2)*qt(4) +  q(3)*qt(1) +  q(4)*qt(2);%y
ret(4) = q(1)*qt(4) +  q(2)*qt(3) -  q(3)*qt(2) +  q(4)*qt(1);%z

if abs(ret(1)) < 0.00000001 
    ret(1) = 0;
end 

if abs(ret(2)) < 0.00000001 
    ret(2) = 0;
end 
 
if abs(ret(3)) < 0.00000001 
    ret(3) = 0;
end 
 
if abs(ret(4)) < 0.00000001 
    ret(4) = 0;
end 

%normalize
size = sqrt(ret(1)*ret(1)+ret(2)*ret(2)+ret(3)*ret(3)+ret(4)*ret(4));
ret = ret / size;

end

