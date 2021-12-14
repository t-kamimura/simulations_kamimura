function calc_error(self,phaseIndex)
    % 誤差の計算
        
    x0 = self.q_ini(1);
    y0 = self.q_ini(2);
    th0 = self.q_ini(3);
    dx0 = self.q_ini(4);
    dy0 = self.q_ini(5);
    dth0 = self.q_ini(6);
    x = self.qout(end, 1);
    y = self.qout(end, 2);
    th = self.qout(end, 3);
    dx = self.qout(end, 4);
    dy = self.qout(end, 5);
    dth = self.qout(end, 6);

    self.mileage = x - x0;
    self.q_err(1) = y - y0;
    self.q_err(2) = th - th0;
    self.q_err(3) = dx - dx0;
    self.q_err(4) = dy - dy0;
    self.q_err(5) = dth - dth0;
    self.q_err_max = max(self.q_err);

    self.v = self.mileage/self.tout(end);

    if phaseIndex == 1
        % disp('reached apex height')
    else
        % disp('gone away')
    end
    
end