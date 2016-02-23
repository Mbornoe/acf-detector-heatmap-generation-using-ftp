function proceed = checkForNoZero( array )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    size(array);
    all(array);
    
    if all(array < 0.5)
        proceed = true;
    else
        proceed = false;
    end
end

