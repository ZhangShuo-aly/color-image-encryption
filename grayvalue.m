%下面涉及到的主要还是公式编程，具体的算法和你的资料一样，我就不详细介绍算法了，如有对函数不理解的再联系我
Gray = imread('.\images\brain.bmp');
[M,N,O] = size(Gray);
%下面2行用于对待大图片，强制截取其一部分，减少运算量，由于是基于统计，所以对结果影响不大
M = 256;            %此2行与19、20行相关，详见19、20行
N = 256;

%--------------------------------------------------------------------------
%1.将各颜色分量转化为灰度，如果图像是灰度图像，就注释掉此段
%  如果未注释此行，运行会出现报错“Index exceeds matrix dimensions.”
%--------------------------------------------------------------------------
%Gray = double(0.3*Gray(:,:,1)+0.59*Gray(:,:,2)+0.11*Gray(:,:,3));

%--------------------------------------------------------------------------
%2.为了减少计算量，对原始图像灰度级压缩，将Gray量化成16级
%--------------------------------------------------------------------------
for i = 1:M
    for j = 1:N
        %for n=1:floor(M+N/2)/16  %如果5、6行被注释，则使用此行。floor函数为向负无穷大方向近似，即近似为等于或小于自己的整数
        for n = 1:256/16        %如果5、6行未注释，则使用此行（其实5、6行注释与否使用上行结果都一样，因为M+N/2==256）
            if (n-1)*16<=Gray(i,j)&Gray(i,j)<=(n-1)*16+15
                Gray(i,j) = n-1;
            end
        end
    end
end

%--------------------------------------------------------------------------
%3.计算四个共生矩阵P,取距离为1，角度分别为0,45,90,135
%--------------------------------------------------------------------------
P = zeros(16,16,4);
for m = 1:16
    for n = 1:16
        for i = 1:M
            for j = 1:N
                if j<N&Gray(i,j)==m-1&Gray(i,j+1)==n-1
                    P(m,n,1) = P(m,n,1)+1;
                    P(n,m,1) = P(m,n,1);
                end
                if i>1&j<N&Gray(i,j)==m-1&Gray(i-1,j+1)==n-1
                    P(m,n,2) = P(m,n,2)+1;
                    P(n,m,2) = P(m,n,2);
                end
                if i<M&Gray(i,j)==m-1&Gray(i+1,j)==n-1
                    P(m,n,3) = P(m,n,3)+1;
                    P(n,m,3) = P(m,n,3);
                end
                if i<M&j<N&Gray(i,j)==m-1&Gray(i+1,j+1)==n-1
                    P(m,n,4) = P(m,n,4)+1;
                    P(n,m,4) = P(m,n,4);
                end
            end
        end
        if m==n
            P(m,n,:) = P(m,n,:)*2;
        end
    end
end

%%---------------------------------------------------------
% 对共生矩阵归一化
%%---------------------------------------------------------
for n = 1:4
    P(:,:,n) = P(:,:,n)/sum(sum(P(:,:,n)));
end

%--------------------------------------------------------------------------
%4.对共生矩阵计算能量、熵、惯性矩、相关4个特征值
%--------------------------------------------------------------------------
H = zeros(1,4);
I = H;
Ux = H;      Uy = H;                                 %通过传递，将各个
deltaX= H;  deltaY = H;                              %要求的参数初始化
C =H;                                                %为4列的零行向量
for n = 1:4
    E(n) = sum(sum(P(:,:,n).^2));                     %求角二阶矩
    for i = 1:16
        for j = 1:16
            if P(i,j,n)~=0
                H(n) = -P(i,j,n)*log(P(i,j,n))+H(n);  %求熵
            end
            I(n) = (i-j)^2*P(i,j,n)+I(n);             %求对比度
           
            Ux(n) = i*P(i,j,n)+Ux(n);                 %相关性中μx
            Uy(n) = j*P(i,j,n)+Uy(n);                 %相关性中μy
        end
    end
end
for n = 1:4
    for i = 1:16
        for j = 1:16
            deltaX(n) = (i-Ux(n))^2*P(i,j,n)+deltaX(n); %相关性中σx
            deltaY(n) = (j-Uy(n))^2*P(i,j,n)+deltaY(n); %相关性中σy
            C(n) = i*j*P(i,j,n)+C(n);             
        end
    end
    C(n) = (C(n)-Ux(n)*Uy(n))/deltaX(n)/deltaY(n);      %求相关度  
end
%显示各个数据，加分号就不显示
E    %能量
H    %熵
I    %对比度
C    %相关度
%画图部分，subplot是将一个窗口划分成若干块，绘图函数和参数我用的不同的，
%你对应着看后然后自己选择修改吧。应该能看懂吧？=。=！
figure;
subplot(2,2,1);stem(E,'filled');title('角二阶矩');       %实心
subplot(2,2,2);stem(H);title('熵');                  %空心
subplot(2,2,3);stem(I,'c');title('对比度');          %改变颜色，一般用英文首字母小写，如红色r，蓝色b
subplot(224);plot(C);title('相关度');              %普通连线

%作者联系hxze220@hotmail.com