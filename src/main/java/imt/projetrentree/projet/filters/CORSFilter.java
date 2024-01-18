package imt.projetrentree.projet.filters;

import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.container.ContainerResponseContext;
import jakarta.ws.rs.container.ContainerResponseFilter;
import jakarta.ws.rs.ext.Provider;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@Provider
public class CORSFilter implements ContainerResponseFilter {

    private static final List<String> allowedOrigins = Arrays.asList("http://localhost:19006", "http://localhost:19007");

    @Override
    public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext)
            throws IOException {

        String origin = requestContext.getHeaderString("Origin");

        if (allowedOrigins.contains(origin)) {
            responseContext.getHeaders().add("Access-Control-Allow-Origin", origin);
        }

        responseContext.getHeaders().add("Access-Control-Allow-Headers", "origin, token, content-type, accept, authorization, x-xsrf-token");
        responseContext.getHeaders().add("Access-Control-Allow-Credentials", "true");
        responseContext.getHeaders().add("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD");
        responseContext.getHeaders().add("Access-Control-Max-Age", "1209600");
    }
}
