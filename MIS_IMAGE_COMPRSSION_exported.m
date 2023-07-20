classdef MIS_IMAGE_COMPRSSION_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        IMAGECOMPRESSIONUSINGSVDLabel  matlab.ui.control.Label
        INPUTIMAGEButton               matlab.ui.control.Button
        COMPRESSIMAGEButton            matlab.ui.control.Button
        COLOURIMAGECheckBox            matlab.ui.control.CheckBox
        GREYSCALEIMAGECheckBox         matlab.ui.control.CheckBox
        Image                          matlab.ui.control.Image
    end

    
    properties (Access = public)
        image_1; % Description
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: INPUTIMAGEButton
        function INPUTIMAGEButtonPushed(app, event)
         
            [filename pathname] = uigetfile({'*.jpg'},"Open file");
            fullpathname = strcat(pathname,filename);
            image1=imread(fullpathname);
            app.Image.ImageSource=image1;
            app.image_1=filename;
        end

        % Button pushed function: COMPRESSIMAGEButton
        function COMPRESSIMAGEButtonPushed(app, event)
           
            
            if(app.GREYSCALEIMAGECheckBox.Value)
                %reading and converting the image
                
                inImage=rgb2gray(app.Image.ImageSource);
                inImageD=double(inImage);
                imwrite(uint8(inImageD), 'original.png');
                % decomposing the image using singular value decomposition
                [U,S,V]=svd(inImageD);
                % Using different number of singular values (diagonal of S) to compress and
                % reconstruct the image
                dispEr = [];
                numSVals = [];
                N = 1;
                 % store the singular values in a temporary var
                 C = S;
                 % discard the diagonal values not required for compression
                 C(N+1:end,:)=0;
                 C(:,N+1:end)=0;
                 % Construct an Image using the selected singular values
                 D=U*C*V';
                 % display and compute error
                 figure;
                 buffer = sprintf('Image output using %d singular values', N)
                 imshow(uint8(D));
                 imwrite(uint8(D), sprintf('%dbw.png', N));
                 title(buffer);
                 error=sum(sum((inImageD-D).^2));
                 % store vals for display
                 dispEr = [dispEr; error];
                 numSVals = [numSVals; N];
                
              
                for N=0:50:300
                 % store the singular values in a temporary var
                 C = S;
                 % discard the diagonal values not required for compression
                 C(N+1:end,:)=0;
                 C(:,N+1:end)=0;
                 % Construct an Image using the selected singular values
                 D=U*C*V';
                 % display and compute error
                 figure;
                 buffer = sprintf('Image output using %d singular values', N)
                 imshow(uint8(D));
                 imwrite(uint8(D), sprintf('%dbw.png', N));
                 title(buffer);
                 error=sum(sum((inImageD-D).^2));
                 % store vals for display
                 dispEr = [dispEr; error];
                 numSVals = [numSVals; N];
                end
                % dislay the error graph
                figure;
                title('Error in compression');
                plot(numSVals, dispEr);
                grid on
                title("Error in Compression");
                xlabel('Number of Singular Values used');
                ylabel('Error between compress and original image');
                R=1:201;
                for i=1:201
                    Xap=U(:,1:i)*S(1:i,1:i)*V(:,1:i)';
                    psne(i)=psnr(Xap,inImageD);
                end
                figure;
                title('PSNR Value in compression');
                plot(R,psne);
                grid on
                title('PSNR Value in compression');
                xlabel('Number of Singular Values used');
                ylabel('PSNR');
                
            elseif(app.COLOURIMAGECheckBox.Value) 
                
                [X] = imread(app.image_1);
                 figure('Name','ORIGINAL component of the imported image');
                 imshow(X);
                 imwrite(X, '!original.jpg');
                 R = X(:,:,1);
                 G = X(:,:,2);
                 B = X(:,:,3);
                 Rimg = cat(3, R, zeros(size(R)), zeros(size(R)));
                 Gimg = cat(3, zeros(size(G)), G, zeros(size(G)));
                 Bimg = cat(3, zeros(size(B)), zeros(size(B)), B);
                 figure('Name','RED component of the imported image');
                 imshow(Rimg);
                 imwrite(Rimg, '!red.jpg');
                 figure('Name','GREEN component of the imported image');
                 imshow(Gimg);
                 imwrite(Gimg, '!green.jpg');
                 figure('Name','BLUE component of the imported image');
                 imshow(Bimg);
                 imwrite(Bimg, '!blue.jpg');
                Red =double(R);
                Green = double(G);
                Blue = double(B);
                N = 1;
                % Compute values for the red image
                [U,S,V]=svd(Red);
                C = S;
                C(N+1:end,:)=0;
                C(:,N+1:end)=0;
                Dr=U*C*V';
                % Rebuild the data back into a displayable image and show it
                figure;
                buffer = sprintf('Red image output using %d singular values', N);
                Rimg = cat(3, Dr, zeros(size(Dr)), zeros(size(Dr)));
                imshow(uint8(Rimg));
                imwrite(uint8(Rimg), sprintf('%dred.jpg', N));
                title(buffer);
                % Compute values for the green image
                [U2, S2, V2]=svd(Green);
                C = S2;
                C(N+1:end,:)=0;
                C(:,N+1:end)=0;
                Dg=U2*C*V2';
                % Rebuild the data back into a displayable image and show it
                figure;
                buffer = sprintf('Green image output using %d singular values', N);
                Gimg = cat(3, zeros(size(Dg)), Dg, zeros(size(Dg)));
                imshow(uint8(Gimg));
                imwrite(uint8(Gimg), sprintf('%dgreen.jpg', N));
                title(buffer);
                % Compute values for the blue image
                [U3, S3, V3]=svd(Blue);
                C = S3;
                C(N+1:end,:)=0;
                C(:,N+1:end)=0;
                Db=U3*C*V3';
                % Rebuild the data back into a displayable image and show it
                figure;
                buffer = sprintf('Blue image output using %d singular values', N);
                Bimg = cat(3, zeros(size(Db)), zeros(size(Db)), Db);
                imshow(uint8(Bimg));
                imwrite(uint8(Bimg), sprintf('%dblue.jpg', N));
                title(buffer);
                % Thake the data from the Red, Green, and Blue image
                % Rebuild a colored image with the corresponding data and show it
                figure;
                buffer = sprintf('Colored image output using %d singular values', N);
                Cimg = cat(3, Dr, Dg, Db);
                imshow(uint8(Cimg));
                imwrite(uint8(Cimg), sprintf('%dcolor.jpg', N));
                title(buffer);
                
                for N=10:25:150
                 % Recompute modes for the red image - already solved by SVD above
                 C = S;
                 C(N+1:end,:)=0;
                 C(:,N+1:end)=0;
                 Dr=U*C*V';
                 % Rebuild the data back into a displayable image and show it
                 figure;
                 buffer = sprintf('Red image output using %d singular values', N);
                 Rimg = cat(3, Dr, zeros(size(Dr)), zeros(size(Dr)));
                 imshow(uint8(Rimg));
                 imwrite(uint8(Rimg), sprintf('%dred.jpg', N));
                 title(buffer);
                 % Recompute modes for the green image - already solved by SVD above
                 C = S2;
                 C(N+1:end,:)=0;
                 C(:,N+1:end)=0;
                 Dg=U2*C*V2';
                 % Rebuild the data back into a displayable image and show it
                 figure;
                 buffer = sprintf('Green image output using %d singular values', N);
                 Gimg = cat(3, zeros(size(Dg)), Dg, zeros(size(Dg)));
                 imshow(uint8(Gimg));
                 imwrite(uint8(Gimg), sprintf('%dgreen.jpg', N));
                 title(buffer);
                 % Recompute modes for the blue image - already solved by SVD above
                 C = S3;
                 C(N+1:end,:)=0;
                 C(:,N+1:end)=0;
                 Db=U3*C*V3';
                 % Rebuild the data back into a displayable image and show it
                 figure;
                 buffer = sprintf('Blue image output using %d singular values', N);
                 Bimg = cat(3, zeros(size(Db)), zeros(size(Db)), Db);
                 imshow(uint8(Bimg));
                 imwrite(uint8(Bimg), sprintf('%dblue.jpg', N));
                 title(buffer);
                 % Thake the data from the Red, Green, and Blue image
                 % Rebuild a colored image with the corresponding data and show it
                 figure;
                 buffer = sprintf('Colored image output using %d singular values', N);
                 Cimg = cat(3, Dr, Dg, Db);
                 imshow(uint8(Cimg));
                 imwrite(uint8(Cimg), sprintf('%dcolor.jpg', N));
                 title(buffer);
                end
         
                
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.9412 0.9412 0.9412];
            app.UIFigure.Position = [100 100 865 582];
            app.UIFigure.Name = 'MATLAB App';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [12 147 426 337];

            % Create GREYSCALEIMAGECheckBox
            app.GREYSCALEIMAGECheckBox = uicheckbox(app.UIFigure);
            app.GREYSCALEIMAGECheckBox.Text = 'GREY-SCALE IMAGE';
            app.GREYSCALEIMAGECheckBox.FontName = 'Times New Roman';
            app.GREYSCALEIMAGECheckBox.FontSize = 14;
            app.GREYSCALEIMAGECheckBox.FontWeight = 'bold';
            app.GREYSCALEIMAGECheckBox.Position = [538 274 211 37];

            % Create COLOURIMAGECheckBox
            app.COLOURIMAGECheckBox = uicheckbox(app.UIFigure);
            app.COLOURIMAGECheckBox.Text = 'COLOUR IMAGE';
            app.COLOURIMAGECheckBox.FontName = 'Times New Roman';
            app.COLOURIMAGECheckBox.FontSize = 14;
            app.COLOURIMAGECheckBox.FontWeight = 'bold';
            app.COLOURIMAGECheckBox.Position = [538 238 211 37];

            % Create COMPRESSIMAGEButton
            app.COMPRESSIMAGEButton = uibutton(app.UIFigure, 'push');
            app.COMPRESSIMAGEButton.ButtonPushedFcn = createCallbackFcn(app, @COMPRESSIMAGEButtonPushed, true);
            app.COMPRESSIMAGEButton.BackgroundColor = [0.7176 0.2745 1];
            app.COMPRESSIMAGEButton.FontName = 'Times New Roman';
            app.COMPRESSIMAGEButton.FontSize = 14;
            app.COMPRESSIMAGEButton.FontWeight = 'bold';
            app.COMPRESSIMAGEButton.Position = [503 58 283 43];
            app.COMPRESSIMAGEButton.Text = 'COMPRESS IMAGE';

            % Create INPUTIMAGEButton
            app.INPUTIMAGEButton = uibutton(app.UIFigure, 'push');
            app.INPUTIMAGEButton.ButtonPushedFcn = createCallbackFcn(app, @INPUTIMAGEButtonPushed, true);
            app.INPUTIMAGEButton.BackgroundColor = [0.7176 0.2745 1];
            app.INPUTIMAGEButton.FontName = 'Times New Roman';
            app.INPUTIMAGEButton.FontSize = 14;
            app.INPUTIMAGEButton.FontWeight = 'bold';
            app.INPUTIMAGEButton.Position = [94 58 283 43];
            app.INPUTIMAGEButton.Text = 'INPUT IMAGE';

            % Create IMAGECOMPRESSIONUSINGSVDLabel
            app.IMAGECOMPRESSIONUSINGSVDLabel = uilabel(app.UIFigure);
            app.IMAGECOMPRESSIONUSINGSVDLabel.BackgroundColor = [0.7176 0.2745 1];
            app.IMAGECOMPRESSIONUSINGSVDLabel.FontName = 'Times New Roman';
            app.IMAGECOMPRESSIONUSINGSVDLabel.FontSize = 22;
            app.IMAGECOMPRESSIONUSINGSVDLabel.FontWeight = 'bold';
            app.IMAGECOMPRESSIONUSINGSVDLabel.Position = [252 509 387 46];
            app.IMAGECOMPRESSIONUSINGSVDLabel.Text = 'IMAGE COMPRESSION USING SVD';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MIS_IMAGE_COMPRSSION_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end