<%
response.setStatus(301);
response.setHeader("Location", "https://www.traccar.org/port-check/");
response.setHeader("Connection", "close");
%>
