function thesisFormat(addedSpace)
% THESISFORMAT Set up current figure with format for main text
% with two figures side-by-side for UCCS thesis
%
% Call this routine after plotting.  Optional input argument = 
% extra space on [left bottom right top] to leave around frame
if nargin < 1,
  addedSpace = [0 0 0 0];
end
SCREENSCALE = 3.0;
addedSpace = addedSpace*SCREENSCALE;

xlim(get(gca,'xlim'));
ylim(get(gca,'ylim'));

% Note that the final figure is scaled down from this...
THINLINEWIDTH = 0.4*SCREENSCALE;
% MEDLINEWIDTH = 1.0;
THICKLINEWIDTH = 1.0*SCREENSCALE;
AXISFONTSIZE   = 7*SCREENSCALE;
XLABELFONTSIZE = 8*SCREENSCALE;
YLABELFONTSIZE = 8*SCREENSCALE;
TITLEFONTSIZE  = 8*SCREENSCALE;
AWIDTH = 2.25*SCREENSCALE; % axis width, in inches
AHEIGHT = AWIDTH*(sqrt(5)-1)/2; % axis height, using golden ratio

% Set default drawing properties
set(gcf,'DefaultAxesLineWidth',THINLINEWIDTH);
set(gcf,'DefaultLineLineWidth',THICKLINEWIDTH);
set(gca,'LineWidth',THINLINEWIDTH);
set(gca,'FontSize',AXISFONTSIZE,'FontName','Times','FontWeight','normal');
set(gca,'XMinorTick','On');
set(gca,'YMinorTick','On');
set(get(gca,'XLabel'),'FontSize',XLABELFONTSIZE,'FontName','Times','FontWeight','normal');
set(get(gca,'YLabel'),'FontSize',YLABELFONTSIZE,'FontName','Times','FontWeight','normal');
set(get(gca,'Title'),'FontSize',TITLEFONTSIZE,'FontName','Times','FontWeight','normal');

set(findobj(gca,'Type','Line'),'LineWidth',THICKLINEWIDTH);
% set(gcf,'Color','none');
% set(gca,'Color','none');

% Save present system of units
funits=get(gcf,'units');
punits=get(gcf,'paperunits');
aunits=get(gca,'units');
set(gca,'units','inches')
set(gcf,'units','inches');
set(gcf,'paperunits','inches');

padBottom = 1.3*(AXISFONTSIZE + XLABELFONTSIZE)/72 + addedSpace(2);
padTop = 1.2*TITLEFONTSIZE/72 + addedSpace(4);
padRight = 0.08*SCREENSCALE + addedSpace(3);
padLeft = 1.1*YLABELFONTSIZE/72 + 0.25*SCREENSCALE + addedSpace(1);

FWIDTH = AWIDTH + padLeft + padRight;
FHEIGHT = AHEIGHT + padTop + padBottom;
a = get(gcf,'position');
set(gcf,'position',[a(1) a(2) FWIDTH FHEIGHT]);
set(gcf,'paperposition',[0 0 FWIDTH FHEIGHT]);
set(gca,'position',[padLeft padBottom AWIDTH AHEIGHT]);


% fix xlabel position
xLabel = get(gca,'xlabel');
xunits = get(xLabel,'units'); set(xLabel,'units','inches');
a = get(xLabel,'position');
set(xLabel,'VerticalAlignment','bottom');
set(xLabel,'position',[a(1) -1.15*(AXISFONTSIZE+XLABELFONTSIZE)/72]);
set(xLabel,'units',xunits);
set(xLabel,'FontWeight','bold');
set(gcf,'color','w');
% fix ylabel position
yLabel = get(gca,'ylabel');
yunits = get(yLabel,'units'); set(yLabel,'units','inches');
a = get(yLabel,'position');
set(yLabel,'VerticalAlignment','top');
set(yLabel,'position',[-padLeft a(2)]);
set(yLabel,'units',yunits);
set(yLabel,'FontWeight','bold');

% fix title position
tLabel = get(gca,'title');
tunits = get(tLabel,'units'); set(tLabel,'units','inches');
a = get(tLabel,'position');
set(tLabel,'VerticalAlignment','bottom');
set(tLabel,'position',[a(1) AHEIGHT + 0.2*TITLEFONTSIZE/72]);
set(tLabel,'units',tunits);
set(tLabel,'FontWeight','bold');

set(gcf,'units',funits);
set(gcf,'paperunits',punits);
set(gca, 'units',aunits)

% set(gcf, 'PaperPositionMode','auto')
drawnow; pause(0.01);