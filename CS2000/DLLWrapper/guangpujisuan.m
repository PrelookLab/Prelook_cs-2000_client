function [XYZ] = guangpujisuan(guangpu,usercmf)
load cmf.mat
[guangpudaxiao,~]=size(guangpu);
if guangpudaxiao == 401 %1nm 380-780
    
    for i=2:13
        
        biseshuju(i-1)=sum(guangpu.*cmf(:,i));
        
    end
    XYZ=zeros(5,6);
    %计算并格式化XYZ
    XYZ(1,1:3)=biseshuju(1,1:3)*683;
    XYZ(2,1:3)=biseshuju(1,4:6)*683;
    XYZ(3,1:3)=biseshuju(1,7:9)*683.358;
    XYZ(4,1:3)=biseshuju(1,10:12)*683.144;

    
  
    %1931 Yxy
 
    [sizex,sizey]=size(usercmf);
    
    if sizex==401 && sizey==3
        
        for j = 1:3
            
            XYZ(5,j)=sum(guangpu.* usercmf(:,j))*683;
            
        end
    end
    
    
    for y=1:5
    XYZ(y,4)=XYZ(y,2);
    XYZ(y,5)=XYZ(y,1)/(XYZ(y,1)+XYZ(y,2)+XYZ(y,3));
    XYZ(y,6)=XYZ(y,2)/(XYZ(y,1)+XYZ(y,2)+XYZ(y,3));
    end
    
elseif guangpudaxiao == 201 %2nm 380-780
    
elseif guangpudaxiao==101 %4nm --380-780
end
end
