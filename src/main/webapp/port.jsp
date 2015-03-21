

<%@ page import="java.io.*, java.net.*" %>

<%

URL url = new URL("http://ports.yougetsignal.com/check-port.php");
HttpURLConnection conn = (HttpURLConnection) url.openConnection();
conn.setRequestMethod("POST");
conn.setDoInput(true);
conn.setDoOutput(true);
conn.setRequestProperty("User-Agent", "Apache-HttpClient/1.0.0 (java 1.5)");

BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(conn.getOutputStream()));
writer.write("remoteAddress=" +request.getParameter("address") + "&portNumber=" + request.getParameter("port"));
writer.close();

conn.connect();

boolean open = false;

if (conn.getResponseCode() == HttpURLConnection.HTTP_OK) {
    BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
    if (in.readLine().contains("open")) {
        open = true;
    }
    in.close();
}

%>

{ "open": <%= open %> }
