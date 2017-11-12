% before running a test, gather necessary information about this test
% so that the result can be recovered easily

% time of excution
	Time_Now = datetime('now');
	FormatOut = 'yy_mm_dd_HH_MM_SS_';
	Time_Begin = datestr(Time_Now,FormatOut);

% system info
	if ismac
		PlatForm = 'Mac_';
	elseif isunix
		PlatForm = 'unix_';
	elseif ispc
		PlatForm = 'Windows_';
	else
		PlatForm = 'unknown_';
	end

% make a directory tagged with time of excution outsider src folder
	% path of this folder. we randomized the last 3 digits to avoid name clashes
	Result_Folder = fullfile('..','exc',[PlatForm Time_Begin num2str(floor(rand()*1000))]); 
	if ~exist(fullfile('..','exc')) % if ../exc does not exist
		mkdir(fullfile('..','exc')) % make this folder
	end
	while exist(Result_Folder) % if this folder name alread exists -- which will probably never happen
		Result_Folder = fullfile('..','exc',[PlatForm Time_Begin num2str(floor(rand()*1000))]); % rename it
	end
	mkdir(Result_Folder) % make a folder
	
% now copy the src code the Result_Folder
	Current_src = fullfile(Result_Folder,'src'); % folder to hold current src files
	mkdir(Current_src)
	copyfile(fullfile('..','src'),Current_src);

% now open a text file and write to it comments and testing info
	Test_info = fopen(fullfile(Result_Folder,'test_info'), 'w');
	fprintf(Test_info, 'test start time : \t');
	fprintf(Test_info, [datestr(Time_Now, 'yy/mm/dd HH:MM:SS'),'\n']);
	fprintf(Test_info, 'some comments \n');
	fprintf(Test_info, 'some comments \n');
	fprintf(Test_info, 'some comments \n');
	fprintf(Test_info, 'some comments \n');
	fclose(Test_info);

D = 0.5;
Alpha = 2;

[x, y, z] = meshgrid(linspace(-pi-D,pi+D,64)/Alpha);

C1 = pi/(2*Alpha); 
C2 = 0.90 * C1/2;

F1 = sqrt(x.^2+y.^2) - (C1-C2*(cos(Alpha * z)+1));
F2 = max(z-pi/Alpha,-z-pi/Alpha);
F = max(F1, F2);

map = SD.SDF3(x,y,z,F)
map.reinitialization(F)

Dt = map.GD3.Dx ^ 4;

loops = 1000;
mov(loops) = struct('cdata',[],'colormap',[]);
%snap{1000} = [];

figure

for ii = 1:-1
	disp(ii);
	A = map.LCF * Dt /2;
	B = map.GD3.Idt + A;
	C = map.GD3.Idt - A;

	F_old = map.F;
	S = C * F_old(:) + Dt * map.NCF(:);
	%F_new = bicg(B, S);
	F_new = bicgstab(B, S, [], 50);
	%F_new = pcg(B, S);
	%map.F = reshape(F_new, map.GD3.Size);
	map.reinitialization( reshape(F_new, map.GD3.Size) );

	map.plotSurface(0,1,'g')
	title(num2str(ii*Dt))
	%map.plot
	drawnow
	mov(ii) = getframe(gcf)

	%snap{ii} = map.F;

	%if (mod(ii,10)==0)
	%	save('snap.mat','snap')
	%end

	datetime('now')

end

save('pinch64mac.mat','mov','DATE')

Elapse = toc;
	
% write test end time

	Test_info = fopen(fullfile(Result_Folder,'test_info.txt'), 'a');
	fprintf(Test_info, 'test end time : \t');
	fprintf(Test_info, [datestr(datetime('now', 'yy/mm/dd HH:MM:SS'),'\n']);
	fclose(Test_info);
