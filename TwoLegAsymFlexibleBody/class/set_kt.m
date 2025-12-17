function kt = set_kt(t,model)
    % Step func
    omega_t = rem(model.omega*t, 2*pi);
    if 0.5*pi < omega_t && omega_t < 1.5*pi
        kt = model.ke;
    else
        kt = model.kg;
    end

    % % sinusoidal func
    % A = (param.ke - param.kg)*0.5;
    % kt = param.kt + A*sin(param.omega0*t);
end