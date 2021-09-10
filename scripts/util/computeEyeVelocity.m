function [x_vel, y_vel, vel_magnitude] = computeEyeVelocity(x_pos,y_pos)
x_vel = zscore([0; diff(x_pos)]);
y_vel = zscore([0; diff(y_pos)]);
vel_magnitude = sqrt(x_vel.^2+y_vel.^2);