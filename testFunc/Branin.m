function [y] = Branin(xx)
y1=Branin_2d(xx);
y2=Branin_2d2(xx);
y3=Branin_2dc(xx);
y=[y1,y2,y3];