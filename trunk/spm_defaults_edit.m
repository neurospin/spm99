function spm_defaults_edit(varargin)
% Modify defaults
% FORMAT spm_defaults_edit
%_______________________________________________________________________
%
% spm_defaults_edit allows the current defaults to be edited.
%
% These changes do not persist across sessions. SPMs startup defaults
% are specified in the first spm_defaults on the MATLABPATH.
%
% The defaults which can be modified are:
% 
% Printing Options
%     Allows a number of different printing defaults to be specified.
% 
% Miscellaneous Defaults
%     This includes:
%     * Specification of a file for logging dialogue between
%       the user and SPM.
%     * Command line input option. Rather than clicking
%       buttons on the interface, input can be typed to
%       the Matlab window.
%     * The intensity of any grid which superimposed on any
%       displayed images.
% 
% Header Defaults (for the currnet Modality - PET or fMRI)
%     The values to be taken as default when there are no Analyze
%     image headers. There are two different sets which depend on
%     the modality in which SPM is running.
%     * image size in x,y and z {voxels}
%     * voxel size in x,y and z {mm}
%     * scaling co-efficient applied to *.img data on entry
%       into SPM. 
%     * data type.  (see spm_type.m for supported types
%       and specifiers)
%     * offest of the image data in file {bytes}
%     * the voxel corresponding the [0 0 0] in the location
%       vector XYZ
%     * a string describing the nature of the image data.
% 
% Realignment & Coregistration Defaults
%     An assortment of defaults.
%
% Spatial Normalisation Defaults
%     An assortment of defaults.
%
% The 'reset' option re-loads the startup defaults from spm_defaults.m
%
%_______________________________________________________________________
% @(#)spm_defaults_edit.m	2.18 John Ashburner  99/10/13
SCCSid = '2.18';

% Programmers Note:
%-----------------------------------------------------------------------
% Batch system implemented on this routine: See spm_bch.man.
% If inputs are modified in this routine, please modify spm_bch.man
% accordingly. 
%-----------------------------------------------------------------------


%-Format arguments
%-----------------------------------------------------------------------
if nargin == 0, Action='!EditMenu'; else, Action = varargin{1}; end


%-Get/setup global defaults variables
%-----------------------------------------------------------------------
global BCH

global MODALITY
global PRINTSTR LOGFILE CMDLINE GRID
global UFp DIM VOX TYPE SCALE OFFSET ORIGIN DESCRIP
global PET_UFp PET_DIM PET_VOX PET_TYPE PET_SCALE PET_OFFSET ...
	PET_ORIGIN PET_DESCRIP
global fMRI_UFp fMRI_DIM fMRI_VOX fMRI_TYPE fMRI_SCALE fMRI_OFFSET ...
	fMRI_ORIGIN fMRI_DESCRIP
global fMRI_T fMRI_T0



switch lower(Action), case '!editmenu'                    %-Defaults menu
%=======================================================================
	SPMid = spm('FnBanner',mfilename,SCCSid);
	spm('FnUIsetup','Defaults Edit');
	spm_help('!ContextHelp',mfilename)

	callbacks = str2mat(...
		'spm_defaults_edit(''Printing'');',...
		'spm_defaults_edit(''Misc'');',...
		'spm_defaults_edit(''Hdr'');',...
		'spm_realign_ui(''Defaults'');',...
		'spm_coreg_ui(''Defaults'');',...
		'spm_sn3d(''Defaults'');',...
		'spm_defaults_edit(''Statistics'');',...
		'spm_defaults_edit(''Reset'');'...
		);

	a1 = spm_input('Defaults Area?',1,'m',...
		['Printing Options|'...
		 'Miscellaneous Defaults|'...
		 'Header Defaults - ',MODALITY,'|'...
		 'Realignment|'...
		 'Coregistration|'...
		 'Spatial Normalisation|'...
		 'Statistics - ',MODALITY,'|'...
		 'Reset All']);
		%- nargin == 0 => not called by batch 

	eval(deblank(callbacks(a1,:)));
	spm_figure('Clear','Interactive');

case 'realign'                          %-Realignment defaults
%=======================================================================

	spm_realign_ui('Defaults');

case 'coreg'                            %-Coreg defaults
%=======================================================================

	spm_coreg_ui('Defaults');

case 'normalisation'                    %-Spatial normalisation defaults
%=======================================================================

	spm_sn3d('Defaults');

case 'misc'                                     %-Miscellaneous defaults
%=======================================================================

	%-Store CMDLINE setting
	c = (abs(CMDLINE)>0) -1;

	if ~isempty(LOGFILE), tmp='yes'; def=1; else, tmp='no'; def=2; end
	if spm_input(['Log to file? (' tmp ')'],2*c,'y/n',[1,0],def,...
      			'batch', {},'log_to_file')
		LOGFILE = ...
			deblank(spm_input('Logfile Name:',2,'s', LOGFILE,...
         'batch', {},'log_file_name'));
	else
		LOGFILE = '';
	end

	CMDLINE = abs(CMDLINE)>0 * sign(CMDLINE);
	def = find(CMDLINE==[0,1,-1]);
	CMDLINE = spm_input('Command Line Input?',3*c,'m',...
		{	'always use GUI',...
			'always use CmdLine',...
			'GUI for files, CmdLine for input'},...
		[0,1,-1],def,'batch',{},'cmdline');

	GRID = spm_input('Grid value (0-1):', 4*c, 'e', GRID,...
      			   'batch',{},'grid');


case 'printing'                                      %-Printing defaults
%=======================================================================

	a0 = spm_input('Printing Mode?', 2, 'm', [...
			'Postscript to File|'...
			'Postscript to Printer|'...
			'Other Format to File|'...
			'Custom'], ...
         'batch', {},'printing_mode');

	if (a0 == 1)
		fname = date; fname(find(fname=='-')) = []; fname = ['spmfig_' fname];
		fname = spm_str_manip(spm_input('Postscript filename:',3,'s',fname,...
         'batch', {},'postscript_filename'),'rtd');

		a1    = spm_input('Postscript Type?', 4, 'm', [...
			'PostScript for black and white printers|'...
			'PostScript for colour printers|'...
			'Level 2 PostScript for black and white printers|'...
			'Level 2 PostScript for colour printers|'...
			'Encapsulated PostScript (EPSF)|'...
			'Encapsulated Colour PostScript (EPSF)|'...
			'Encapsulated Level 2 PostScript (EPSF)|'...
			'Encapsulated Level 2 Color PostScript (EPSF)|'...
			'Encapsulated                with TIFF preview|'...
			'Encapsulated Colour         with TIFF preview|'...
			'Encapsulated Level 2        with TIFF preview|'...
			'Encapsulated Level 2 Colour with TIFF preview|'],...
                        'batch', {},'postscript_type');

		prstr1 = str2mat(...
			['print(''-noui'',''-painters'',''-dps'' ,''-append'',''' fname '.ps'');'],...
			['print(''-noui'',''-painters'',''-dpsc'',''-append'',''' fname '.ps'');'],...
			['print(''-noui'',''-painters'',''-dps2'',''-append'',''' fname '.ps'');'],...
			['print(''-noui'',''-painters'',''-dpsc2'',''-append'',''' fname '.ps'');']);
		prstr1 = str2mat(prstr1,...
			['global PAGENUM;if isempty(PAGENUM),PAGENUM = 1;end;'...
			 'print(''-noui'',''-painters'',''-deps'',[''' fname '_'' num2str(PAGENUM) ''.ps'']); PAGENUM = PAGENUM + 1;'],...
			['global PAGENUM;if isempty(PAGENUM),PAGENUM = 1;end;'...
			 'print(''-noui'',''-painters'',''-depsc'',[''' fname '_'' num2str(PAGENUM) ''.ps'']); PAGENUM = PAGENUM + 1;'],...
			['global PAGENUM;if isempty(PAGENUM),PAGENUM = 1;end;'...
			 'print(''-noui'',''-painters'',''-deps2'',[''' fname '_'' num2str(PAGENUM) ''.ps'']); PAGENUM = PAGENUM + 1;'],...
			['global PAGENUM;if isempty(PAGENUM),PAGENUM = 1;end;'...
			 'print(''-noui'',''-painters'',''-depsc2'',[''' fname '_'' num2str(PAGENUM) ''.ps'']); PAGENUM = PAGENUM + 1;'],...
			['global PAGENUM;if isempty(PAGENUM),PAGENUM = 1;end;'...
			 'print(''-noui'',''-painters'',''-deps'',''-tiff'',[''' fname '_'' num2str(PAGENUM) ''.ps'']); PAGENUM = PAGENUM + 1;'],...
			['global PAGENUM;if isempty(PAGENUM),PAGENUM = 1;end;'...
			 'print(''-noui'',''-painters'',''-depsc'',''-tiff'',[''' fname '_'' num2str(PAGENUM) ''.ps'']); PAGENUM = PAGENUM + 1;'],...
			['global PAGENUM;if isempty(PAGENUM),PAGENUM = 1;end;'...
			 'print(''-noui'',''-painters'',''-deps2'',''-tiff'',[''' fname '_'' num2str(PAGENUM) ''.ps'']); PAGENUM = PAGENUM + 1;'],...
			['global PAGENUM;if isempty(PAGENUM),PAGENUM = 1;end;'...
			 'print(''-noui'',''-painters'',''-depsc2'',''-tiff'',[''' fname '_'' num2str(PAGENUM) ''.ps'']); PAGENUM = PAGENUM + 1;']);
		PRINTSTR = deblank(prstr1(a1,:));
	elseif (a0 == 2)
		printer = '';
		if (spm_input('Default Printer?', 3, 'y/n', ...
     			'batch', {},'default_printer') == 'n')
			printer = spm_input('Printer Name:',3,'s',...
                                  'batch', {},'printer_name')
			printer = [' -P' printer];
		end
		a1 = spm_input('Postscript Type:',4,'b','B & W|Colour', ...
                         str2mat('-dps', '-dpsc'),...
			'batch', {},'post_type');
		PRINTSTR = ['print -noui -painters ' a1 printer];
	elseif (a0 == 3)
		fname = date; fname(find(fname=='-')) = []; fname = ['spmfig_' fname];
		fname = spm_str_manip(spm_input('Graphics filename:',3,'s', fname,'batch', {},'graphics_filename'),'rtd');
		a1    = spm_input('Graphics Type?', 4, 'm', [...
			'HPGL compatible with Hewlett-Packard 7475A plotter|'...
			'Adobe Illustrator 88 compatible illustration file|'...
			'M-file (and Mat-file, if necessary)|'...
			'Baseline JPEG image|'...
			'TIFF with packbits compression|'...
			'Color image format|'],...
         'batch', {},'graph_type');
		prstr1 = str2mat(...
			['global PAGENUM;if isempty(PAGENUM),PAGENUM = 1;end;'...
			 'print(''-noui'',''-painters'',''-dhpgl'',[''' fname '_'' num2str(PAGENUM) ''.hpgl'']); PAGENUM = PAGENUM + 1;'],...
			['global PAGENUM;if isempty(PAGENUM),PAGENUM = 1;end;'...
			 'print(''-noui'',''-painters'',''-dill'',[''' fname '_'' num2str(PAGENUM) ''.ill'']); PAGENUM = PAGENUM + 1;'],...
			['global PAGENUM;if isempty(PAGENUM),PAGENUM = 1;end;'...
			 'print(''-noui'',''-painters'',''-dmfile'',[''' fname '_'' num2str(PAGENUM) ''.m'']); PAGENUM = PAGENUM + 1;'],...
			['global PAGENUM;if isempty(PAGENUM),PAGENUM = 1;end;'...
			 'print(''-noui'',''-painters'',''-djpeg'',[''' fname '_'' num2str(PAGENUM) ''.jpeg'']); PAGENUM = PAGENUM + 1;'],...
			['global PAGENUM;if isempty(PAGENUM),PAGENUM = 1;end;'...
			 'print(''-noui'',''-painters'',''-dtiff'',[''' fname '_'' num2str(PAGENUM) ''.tiff'']); PAGENUM = PAGENUM + 1;'],...
			['global PAGENUM;if isempty(PAGENUM),PAGENUM = 1;end;'...
			 'print(''-noui'',''-painters'',''-dtiffnocompression'',[''' fname '_'' num2str(PAGENUM) ''.tiff'']); PAGENUM = PAGENUM + 1;']);
		PRINTSTR = deblank(prstr1(a1,:));
	else
		PRINTSTR = spm_input('Print String',3,'s',...
      'batch',{},'print_string');
	end

case 'hdr'                                             %-Header defaults
%=======================================================================

	DIM = spm_input('Image size {voxels}',2,'n',DIM(:)',[1,3],...
		'batch',{},'image_size_voxels');

	VOX = spm_input('Voxel Size {mm}',3,'r',VOX(:)',[1,3],[0,Inf],...
		'batch',{},'voxel_size_mm');

	SCALE = spm_input('Scaling Coefficient',4,'r',SCALE,1,...
		'batch',{},'scale');

	TYPE = spm_input('Data Type',5,'m',...
		{	'Unsigned Char  ( 8 bit)',...
			'Signed Short (16 bit)',...
			'Signed Integer (32 bit)',...
			'Floating Point',...
			'Double Precision'},...
		[2 4 8 16 64],find([2 4 8 16 64]==TYPE),...
		'batch', {},'data_type');

	OFFSET = spm_input('Offset  {bytes}',6,'w',OFFSET,1,...
		'batch',{},'offset');

	ORIGIN = spm_input('Origin {voxels}',7,'i',ORIGIN(:)',[1,3],...
		'batch',{},'origin_voxels');

	DESCRIP = spm_input('Description',8,'s',DESCRIP,...
		'batch',{},'description');

	if strcmp(MODALITY,'PET')
		PET_DIM       = DIM;
		PET_VOX       = VOX;
		PET_TYPE      = TYPE;
		PET_SCALE     = SCALE;
		PET_OFFSET    = OFFSET;
		PET_ORIGIN    = ORIGIN;
		PET_DESCRIP   = DESCRIP;
	elseif strcmp(MODALITY,'FMRI')
		fMRI_DIM      = DIM;
		fMRI_VOX      = VOX;
		fMRI_TYPE     = TYPE;
		fMRI_SCALE    = SCALE;
		fMRI_OFFSET   = OFFSET;
		fMRI_ORIGIN   = ORIGIN;
		fMRI_DESCRIP  = DESCRIP;
	end


case 'statistics'                                       %-Stats defaults
%=======================================================================

	UFp = spm_input('Upper tail F prob. threshold',2,'e',UFp,1, ...
  			  'batch', {},'F_threshold');
	if strcmp(MODALITY,'PET')
		PET_UFp  = UFp;
	elseif strcmp(MODALITY,'FMRI')
		fMRI_UFp = UFp;
	end
	if strcmp(MODALITY,'FMRI'),
		fMRI_T  = spm_input('Number of Bins/TR' ,3,'n',fMRI_T,1,...
  			  'batch', {},'fMRI_T');
		fMRI_T0 = spm_input('Sampled bin',4,'n',fMRI_T0,1, fMRI_T,...
  			  'batch', {},'fMRI_T0');
	end;


case 'reset'                                            %-Reset defaults
%=======================================================================
	if exist('spm_defaults')==2
		spm_defaults;
	end
   if isempty(BCH)	
      	spm('chmod',MODALITY);
   else
      	spm('defaults',MODALITY);
   end


otherwise
%=======================================================================
error(['Invalid type/action: ',Action])


%=======================================================================
end

