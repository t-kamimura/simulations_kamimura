function kt = set_kt(t,model)
    % Step func
    if rem(model.omega*t, 2*pi)<pi
        kt = model.ke;
    else
        kt = model.kg;
    end

    % % sinusoidal func
    % A = (param.ke - param.kg)*0.5;
    % kt = param.kt + A*sin(param.omega0*t);
end