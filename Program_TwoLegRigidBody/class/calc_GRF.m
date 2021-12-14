function calc_GRF(model)
    
    model.GRF = model.kh*(model.l3 - min(model.lout(:,1)));
            
    % 力積の計算
    p = 0;
    for i_t = 2:length(model.tout)
        p = p + model.kh*(model.l3 - model.lout(i_t,1))*cos(model.gout(i_t,1))*(model.tout(i_t)-model.tout(i_t-1));
    end
    model.p = p;

end