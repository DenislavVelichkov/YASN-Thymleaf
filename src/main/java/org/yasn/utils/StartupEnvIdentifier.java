package org.yasn.utils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.core.env.Environment;

import javax.annotation.PostConstruct;
import java.util.Arrays;

@Component
public class StartupEnvIdentifier {
    @Autowired
    private Environment env;

    @PostConstruct
    public void logActiveProfiles() {
        System.out.println("Active profiles: " + Arrays.toString(env.getActiveProfiles()));
    }
}
