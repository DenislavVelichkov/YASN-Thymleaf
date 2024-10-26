package org.yasn.utils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.core.env.Environment;

import javax.annotation.PostConstruct;
import java.util.Arrays;

@Component
public class StartupEnvIdentifier  implements ApplicationRunner {

    @Autowired
    private Environment env;

    @Value("${spring.datasource.url}")
    private String datasourceUrl;

    @PostConstruct
    public void logActiveProfiles() {
        System.out.println("Active profiles: " + Arrays.toString(env.getActiveProfiles()));
    }

    @PostConstruct
    public void logDatabaseUrl() {
        System.out.println("Configured Database URL: " + datasourceUrl);
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        System.out.println("Configured Database URL: " + datasourceUrl);

    }
}
