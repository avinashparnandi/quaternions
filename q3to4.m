function ret = q3to4( q )

ret(1) = sqrt(max(0,1-( q(1) * q(1) + q(2) * q(2) + q(3) * q(3) )))

ret(2) = q(1);
ret(3) = q(2);
ret(4) = q(3);

end

