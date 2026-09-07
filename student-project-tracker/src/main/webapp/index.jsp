<%@ page import="java.util.*, java.io.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // ============================================================
    // 1. DATA STORAGE (Using a file in the server)
    //    This replaces localStorage - data stays even after restart!
    // ============================================================
    String dataFile = application.getRealPath("/") + "projects.txt";
    List<String[]> projects = new ArrayList<>();
    
    // Load existing projects from file
    try (BufferedReader reader = new BufferedReader(new FileReader(dataFile))) {
        String line;
        while ((line = reader.readLine()) != null) {
            String[] parts = line.split("\\|");
            if (parts.length == 4) {
                projects.add(parts);
            }
        }
    } catch (FileNotFoundException e) {
        // File doesn't exist yet - that's fine
    }
    
    // ============================================================
    // 2. HANDLE FORM ACTIONS (Add, Edit, Delete)
    // ============================================================
    String action = request.getParameter("action");
    String idParam = request.getParameter("id");
    
    if ("add".equals(action)) {
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String status = request.getParameter("status");
        String dueDate = request.getParameter("dueDate");
        
        if (name != null && dueDate != null) {
            String id = String.valueOf(System.currentTimeMillis());
            projects.add(new String[]{id, name, description, status, dueDate});
        }
    }
    
    if ("delete".equals(action) && idParam != null) {
        projects.removeIf(p -> p[0].equals(idParam));
    }
    
    if ("edit".equals(action) && idParam != null) {
        // Find project and pre-fill form
        for (String[] p : projects) {
            if (p[0].equals(idParam)) {
                request.setAttribute("editId", p[0]);
                request.setAttribute("editName", p[1]);
                request.setAttribute("editDescription", p[2]);
                request.setAttribute("editStatus", p[3]);
                request.setAttribute("editDueDate", p[4]);
            }
        }
    }
    
    if ("update".equals(action) && idParam != null) {
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String status = request.getParameter("status");
        String dueDate = request.getParameter("dueDate");
        
        for (String[] p : projects) {
            if (p[0].equals(idParam)) {
                p[1] = name;
                p[2] = description;
                p[3] = status;
                p[4] = dueDate;
                break;
            }
        }
    }
    
    // Save everything back to file
    try (PrintWriter writer = new PrintWriter(new FileWriter(dataFile))) {
        for (String[] p : projects) {
            writer.println(String.join("|", p));
        }
    } catch (Exception e) {}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Project Tracker</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen flex items-center justify-center p-4">

    <main class="bg-white rounded-2xl shadow-xl p-6 w-full max-w-6xl">
        <header class="mb-6">
            <h1 class="text-3xl font-bold text-gray-800">📋 STUDENT PROJECT TRACKER</h1>
            <p class="text-sm text-gray-500">Built with Java JSP</p>
        </header>

        <!-- ============================================================ -->
        <!-- 3. ADD/EDIT FORM                                              -->
        <!-- ============================================================ -->
        <section class="bg-gray-50 p-4 rounded-xl border border-gray-200 mb-8">
            <h2 class="text-lg font-semibold text-gray-700 mb-3">
                <%= request.getAttribute("editId") != null ? "✏️ Edit Project" : "➕ Add a New Project" %>
            </h2>
            
            <form method="POST" class="grid grid-cols-1 md:grid-cols-4 gap-4">
                <% if (request.getAttribute("editId") != null) { %>
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= request.getAttribute("editId") %>">
                <% } else { %>
                    <input type="hidden" name="action" value="add">
                <% } %>
                
                <input type="text" name="name" placeholder="Project name" required 
                       value="<%= request.getAttribute("editName") != null ? request.getAttribute("editName") : "" %>"
                       class="px-3 py-2 border rounded-lg focus:ring-2 focus:ring-indigo-400">
                
                <input type="text" name="description" placeholder="Description" 
                       value="<%= request.getAttribute("editDescription") != null ? request.getAttribute("editDescription") : "" %>"
                       class="px-3 py-2 border rounded-lg focus:ring-2 focus:ring-indigo-400">
                
                <select name="status" class="px-3 py-2 border rounded-lg focus:ring-2 focus:ring-indigo-400">
                    <option value="Not Started" <%= "Not Started".equals(request.getAttribute("editStatus")) ? "selected" : "" %>>Not Started</option>
                    <option value="In Progress" <%= "In Progress".equals(request.getAttribute("editStatus")) ? "selected" : "" %>>In Progress</option>
                    <option value="Completed" <%= "Completed".equals(request.getAttribute("editStatus")) ? "selected" : "" %>>Completed</option>
                </select>
                
                <input type="date" name="dueDate" required 
                       value="<%= request.getAttribute("editDueDate") != null ? request.getAttribute("editDueDate") : "" %>"
                       class="px-3 py-2 border rounded-lg focus:ring-2 focus:ring-indigo-400">
                
                <div class="md:col-span-4">
                    <button type="submit" class="bg-indigo-600 hover:bg-indigo-700 text-white font-medium px-6 py-2 rounded-lg transition">
                        <%= request.getAttribute("editId") != null ? "Update Project" : "Add Project" %>
                    </button>
                    <% if (request.getAttribute("editId") != null) { %>
                        <a href="index.jsp" class="bg-gray-400 hover:bg-gray-500 text-white font-medium px-6 py-2 rounded-lg transition ml-2">
                            Cancel
                        </a>
                    <% } %>
                </div>
            </form>
        </section>

        <!-- ============================================================ -->
        <!-- 4. PROJECT TABLE                                              -->
        <!-- ============================================================ -->
        <section>
            <h2 class="text-lg font-semibold text-gray-700 mb-3">Your Projects</h2>
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
                            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Due Date</th>
                            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        <% if (projects.isEmpty()) { %>
                            <tr>
                                <td colspan="5" class="px-4 py-6 text-center text-gray-400">
                                    No projects yet. Add one above!
                                </td>
                            </tr>
                        <% } else { %>
                            <% for (String[] p : projects) { 
                                String statusColor = "bg-yellow-200 text-yellow-800";
                                if (p[3].equals("Completed")) statusColor = "bg-green-200 text-green-800";
                                if (p[3].equals("Not Started")) statusColor = "bg-blue-200 text-blue-800";
                            %>
                                <tr>
                                    <td class="px-4 py-3 text-sm font-medium"><%= p[1] %></td>
                                    <td class="px-4 py-3 text-sm text-gray-600"><%= p[2] != null && !p[2].isEmpty() ? p[2] : "—" %></td>
                                    <td class="px-4 py-3 text-sm">
                                        <span class="px-2 py-1 rounded-full text-xs font-semibold <%= statusColor %>">
                                            <%= p[3] %>
                                        </span>
                                    </td>
                                    <td class="px-4 py-3 text-sm"><%= p[4] %></td>
                                    <td class="px-4 py-3 text-sm">
                                        <a href="index.jsp?action=edit&id=<%= p[0] %>" 
                                           class="text-indigo-600 hover:text-indigo-800 font-medium mr-3">
                                            ✏️ Edit
                                        </a>
                                        <a href="index.jsp?action=delete&id=<%= p[0] %>" 
                                           onclick="return confirm('Delete this project?')"
                                           class="text-red-600 hover:text-red-800 font-medium">
                                            🗑️ Delete
                                        </a>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>
    </main>

</body>
</html>