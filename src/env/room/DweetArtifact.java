package room;

import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.CompletableFuture;

import cartago.Artifact;
import cartago.OPERATION;


/**
 * A CArtAgO artifact that provides an operation for sending messages to agents 
 * with KQML performatives using the dweet.io API
 */
public class DweetArtifact extends Artifact {

    void init() {
    }
        
 

    @OPERATION
    void sendDweet(String message) {
        try {
            try {
                var urlEncoded = "dweet-artifact-of-Jan?message=" + URLEncoder.encode(message, StandardCharsets.UTF_8.toString());
                System.out.println("url Encoded: " + urlEncoded);
            
                HttpRequest request = HttpRequest
                        .newBuilder(new URI("https://dweet.io/dweet/for/"+urlEncoded))
                        .GET()
                        .build();

                CompletableFuture<HttpResponse<String>> response = HttpClient.newBuilder().build()
                        .sendAsync(request, HttpResponse.BodyHandlers.ofString());
                int statusCode = response.join().statusCode();
                System.out.println("status code: " + statusCode);
                
            } catch (UnsupportedEncodingException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        } catch (URISyntaxException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
    
}
