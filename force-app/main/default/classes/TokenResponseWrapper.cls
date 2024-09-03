public class TokenResponseWrapper {
    public String access_token;
    public Integer expires_in;
    public Integer refresh_expires_in;
    public String token_type;
    
    public static TokenResponseWrapper parse(String json) {
        return (TokenResponseWrapper) System.JSON.deserialize(json, TokenResponseWrapper.class);
    }
}