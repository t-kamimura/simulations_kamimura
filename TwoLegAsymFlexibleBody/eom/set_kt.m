function kt = set_kt(t,model)
    if rem(model.omega0*t, 2*pi)<pi
        kt = model.ke;
    else
        kt = model.kg;
    end
end