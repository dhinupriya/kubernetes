package com.JavaAppKubernetes.demo;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/Hello")
public class Controller {

    @Value("${info.app.name:Demo App}")
    private String appName;

    @Value("${info.app.version:1.0.0}")
    private String appVersion;

    @GetMapping("/World")
    public String getHello() throws UnknownHostException {
        String hostname = InetAddress.getLocalHost().getHostName();
        String podName = System.getenv().getOrDefault("POD_NAME", "unknown");
        return String.format("Hello! Welcome to Kubernetes Demo. Pod: %s (Hostname: %s)", 
                            podName, hostname);
    }

    @GetMapping("/info")
    public Map<String, Object> info() throws UnknownHostException {
        Map<String, Object> info = new HashMap<>();
        
        info.put("hostname", InetAddress.getLocalHost().getHostName());
        info.put("podName", System.getenv().getOrDefault("POD_NAME", "unknown"));
        info.put("podNamespace", System.getenv().getOrDefault("POD_NAMESPACE", "default"));
        info.put("appName", System.getenv().getOrDefault("APPLICATION_NAME", appName));
        info.put("environment", System.getenv().getOrDefault("ENVIRONMENT", "unknown"));
        info.put("logLevel", System.getenv().getOrDefault("LOG_LEVEL", "INFO"));
        info.put("version", appVersion);
        info.put("timestamp", LocalDateTime.now().toString());
        
        return info;
    }

    @GetMapping("/env")
    public Map<String, String> getEnv() {
        Map<String, String> envVars = new HashMap<>();
        
        envVars.put("APPLICATION_NAME", System.getenv().getOrDefault("APPLICATION_NAME", "not-set"));
        envVars.put("ENVIRONMENT", System.getenv().getOrDefault("ENVIRONMENT", "not-set"));
        envVars.put("LOG_LEVEL", System.getenv().getOrDefault("LOG_LEVEL", "not-set"));
        envVars.put("POD_NAME", System.getenv().getOrDefault("POD_NAME", "not-set"));
        envVars.put("POD_NAMESPACE", System.getenv().getOrDefault("POD_NAMESPACE", "not-set"));
        envVars.put("DATABASE_PASSWORD", System.getenv().getOrDefault("DATABASE_PASSWORD", "not-set") != null ? "***HIDDEN***" : "not-set");
        envVars.put("API_KEY", System.getenv().getOrDefault("API_KEY", "not-set") != null ? "***HIDDEN***" : "not-set");
        
        return envVars;
    }
}
