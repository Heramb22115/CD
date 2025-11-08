import streamlit as st
import graphviz  # For rendering the graph
import ast       # Python's built-in Abstract Syntax Tree module

# --- Section 1: Custom AST Node Classes ---
# (Expanded with a new 'LabelNode')

class Node:
    """Base class for all AST nodes."""
    def visit(self, visitor):
        method_name = f"_visit_{self.__class__.__name__}"
        visitor_method = getattr(visitor, method_name, visitor._visit_default)
        return visitor_method(self)

class StatementList(Node):
    def __init__(self, statements):
        self.statements = statements

class Assignment(Node):
    def __init__(self, variable, expression):
        self.variable = variable
        self.expression = expression

class Condition(Node):
    def __init__(self, text):
        self.text = text

class IfElse(Node):
    def __init__(self, condition, then_block, else_block):
        self.condition = condition
        self.then_block = then_block
        self.else_block = else_block
        # NEW: We will store the actual LabelNode objects here
        self.false_label_node = None 
        self.end_label_node = None   

class While(Node):
    def __init__(self, condition, body_block):
        self.condition = condition
        self.body_block = body_block
        self.start_label_node = None 
        self.end_label_node = None   

class For(Node):
    def __init__(self, target, iter_obj, body_block):
        self.target = target
        self.iter_obj = iter_obj
        self.body_block = body_block
        self.start_label_node = None
        self.end_label_node = None

class FunctionDef(Node):
    def __init__(self, name, args_text, body_block):
        self.name = name
        self.args_text = args_text
        self.body_block = body_block

class Return(Node):
    def __init__(self, value_text):
        self.value_text = value_text

class ExpressionStatement(Node):
    def __init__(self, expression_node):
        self.expression_node = expression_node

class FunctionCall(Node):
    def __init__(self, func_name, args_text):
        self.func_name = func_name
        self.args_text = args_text

# --- NEW NODE TYPE ---
class LabelNode(Node):
    """NEW: Represents a label in the code (e.g., 'L0:')."""
    def __init__(self, name):
        self.name = name


# --- Section 2: Label Generator & Visitor ---
# (Updated to insert LabelNode objects into the AST)

class LabelGenerator:
    def __init__(self, prefix="L"):
        self.counter = 0
        self.prefix = prefix

    def get_new_label_node(self):
        """NEW: Creates and returns a new LabelNode."""
        name = f"{self.prefix}{self.counter}"
        self.counter += 1
        return LabelNode(name)

class ASTLabelVisitor:
    """
    Traverses the AST and attaches LabelNode objects.
    """
    def __init__(self, label_generator):
        self.label_gen = label_generator

    def visit(self, node):
        if node is None:
            return
        return node.visit(self)

    def _visit_default(self, node):
        pass

    def _visit_StatementList(self, node):
        # NEW: We need to insert labels *between* statements
        # This is complex, so for this demo, we'll just
        # visit the children. A full implementation
        # would modify the statements list.
        for statement in node.statements:
            self.visit(statement)

    def _visit_IfElse(self, node):
        # NEW: Assign the actual node objects
        node.false_label_node = self.label_gen.get_new_label_node()
        node.end_label_node = self.label_gen.get_new_label_node()
        self.visit(node.condition)
        self.visit(node.then_block)
        if node.else_block:
            self.visit(node.else_block)

    def _visit_While(self, node):
        node.start_label_node = self.label_gen.get_new_label_node()
        node.end_label_node = self.label_gen.get_new_label_node()
        self.visit(node.condition)
        self.visit(node.body_block)

    def _visit_For(self, node):
        node.start_label_node = self.label_gen.get_new_label_node()
        node.end_label_node = self.label_gen.get_new_label_node()
        self.visit(node.body_block)

    def _visit_FunctionDef(self, node):
        self.visit(node.body_block)
        
    # Other nodes don't need labels
    def _visit_ExpressionStatement(self, node): pass
    def _visit_Assignment(self, node): pass
    def _visit_Condition(self, node): pass
    def _visit_Return(self, node): pass
    def _visit_FunctionCall(self, node): pass
    def _visit_LabelNode(self, node): pass


# --- Section 3: Python AST-to-Custom AST Converter ---
# (This remains unchanged from the previous version)

class ASTConverter(ast.NodeVisitor):
    def to_string(self, node):
        if node is None: return None
        if isinstance(node, ast.Constant): return repr(node.value)
        try: return ast.unparse(node)
        except: return "..."

    def visit_Module(self, node):
        statements = [self.visit(stmt) for stmt in node.body]
        return StatementList([s for s in statements if s is not None])

    def visit_If(self, node):
        condition = self.visit(node.test)
        then_block = StatementList([self.visit(stmt) for stmt in node.body])
        else_block = StatementList([self.visit(stmt) for stmt in node.orelse]) if node.orelse else None
        return IfElse(condition, then_block, else_block)

    def visit_While(self, node):
        condition = self.visit(node.test)
        body_block = StatementList([self.visit(stmt) for stmt in node.body])
        return While(condition, body_block)

    def visit_For(self, node):
        target = self.to_string(node.target)
        iter_obj = self.to_string(node.iter)
        body_block = StatementList([self.visit(stmt) for stmt in node.body])
        return For(target, iter_obj, body_block)

    def visit_FunctionDef(self, node):
        name = node.name
        args_text = self.to_string(node.args)
        body_block = StatementList([self.visit(stmt) for stmt in node.body])
        return FunctionDef(name, args_text, body_block)
    
    def visit_Return(self, node):
        value_text = self.to_string(node.value)
        return Return(value_text)

    def visit_Assign(self, node):
        variable = self.to_string(node.targets[0])
        expression = self.to_string(node.value)
        return Assignment(variable, expression)

    def visit_Expr(self, node):
        expression_node = self.visit(node.value)
        return ExpressionStatement(expression_node)

    def visit_Call(self, node):
        func_name = self.to_string(node.func)
        args_text = [self.to_string(arg) for arg in node.args]
        return FunctionCall(func_name, args_text)

    def visit_Compare(self, node):
        return Condition(self.to_string(node))
        
    def visit_Name(self, node):
        return Condition(self.to_string(node))
    
    def generic_visit(self, node):
        return None # Ignore nodes we don't handle


# --- Section 4: NEW Control Flow Graph (CFG) Visitor ---
# (This is a complete rewrite of the GraphvizVisitor)

class CFGVisualizer:
    """
    NEW: Builds a true Control Flow Graph (CFG).
    The 'visit' methods now return (start_node_id, end_node_id)
    to allow for correct block linking.
    """
    def __init__(self):
        self.dot = graphviz.Digraph()
        self.node_counter = 0
        self.labels = {} # Keep track of visited labels

    def get_new_node_id(self):
        self.node_counter += 1
        return f"n{self.node_counter}"
    
    def add_node(self, label, shape="box", style="filled", fillcolor="whitesmoke"):
        """Helper to create a new graph node."""
        node_id = self.get_new_node_id()
        self.dot.node(node_id, label=label, shape=shape, style=style, fillcolor=fillcolor)
        return node_id
    
    def add_edge(self, from_id, to_id, label=None):
        """Helper to create a new graph edge."""
        self.dot.edge(from_id, to_id, label=label)
    
    def visit(self, node):
        if node is None:
            return (None, None)
        return node.visit(self)
    
    def _visit_default(self, node):
        node_id = self.add_node(f"<{node.__class__.__name__}>", shape="plaintext", fillcolor="gray")
        return (node_id, node_id) # (start, end)

    def _visit_StatementList(self, node):
        """Links all statements in the list sequentially."""
        if not node.statements:
            return (None, None)
        
        # Visit the first statement
        (prev_start, prev_end) = self.visit(node.statements[0])
        first_start = prev_start
        
        # Visit the rest, linking them
        for stmt in node.statements[1:]:
            (curr_start, curr_end) = self.visit(stmt)
            if curr_start:
                self.add_edge(prev_end, curr_start) # Link end of prev to start of curr
                prev_end = curr_end
                
        return (first_start, prev_end) # (Start of first, End of last)

    def _visit_Assignment(self, node):
        node_id = self.add_node(f"{node.variable} = {node.expression}")
        return (node_id, node_id)

    def _visit_FunctionCall(self, node):
        node_id = self.add_node(f"Call: {node.func_name}({', '.join(node.args_text)})", style="rounded,filled")
        return (node_id, node_id)
        
    def _visit_ExpressionStatement(self, node):
        # Just visit the inner expression
        return self.visit(node.expression_node)

    def _visit_Return(self, node):
        node_id = self.add_node(f"Return {node.value_text or ''}", fillcolor="moccasin", shape="invhouse")
        return (node_id, node_id)

    def _visit_LabelNode(self, node):
        """Creates an actual label node."""
        if node.name not in self.labels:
             self.labels[node.name] = self.add_node(f"{node.name}:", shape="plaintext", fillcolor="white")
        
        node_id = self.labels[node.name]
        return (node_id, node_id)

    def _visit_IfElse(self, node):
        # 1. Create the nodes
        cond_id = self.add_node(f"If ({node.condition.text})", shape="diamond", fillcolor="lightblue")
        
        # 2. Get the label nodes
        (false_label_id, _) = self.visit(node.false_label_node)
        (end_label_id, _) = self.visit(node.end_label_node)
        
        # 3. Visit the blocks
        (then_start, then_end) = self.visit(node.then_block)
        (else_start, else_end) = self.visit(node.else_block)
        
        # 4. Link the condition
        self.add_edge(cond_id, then_start, "True")
        
        # 5. Link the 'false' path
        if else_start:
            # If there is an 'else' block, jump to it
            self.add_edge(cond_id, false_label_id, f"False ({node.false_label_node.name})")
            self.add_edge(false_label_id, else_start)
            self.add_edge(else_end, end_label_id, "goto") # Link end of else to end label
        else:
            # If no 'else' block, jump straight to the end
            self.add_edge(cond_id, end_label_id, f"False ({node.false_label_node.name})")

        # 6. Link the 'then' block to the end
        self.add_edge(then_end, end_label_id, "goto")
        
        return (cond_id, end_label_id) # (Start of if, End of block)

    def _visit_While(self, node):
        # 1. Get the label nodes
        (start_label_id, _) = self.visit(node.start_label_node)
        (end_label_id, _) = self.visit(node.end_label_node)
        
        # 2. Create the condition node
        cond_id = self.add_node(f"While ({node.condition.text})", shape="oval", fillcolor="lightyellow")
        
        # 3. Visit the body
        (body_start, body_end) = self.visit(node.body_block)
        
        # 4. Link the flow
        self.add_edge(start_label_id, cond_id) # 1. Enter loop at start label
        self.add_edge(cond_id, body_start, "True") # 2. If true, enter body
        self.add_edge(cond_id, end_label_id, "False") # 3. If false, jump to end
        self.add_edge(body_end, start_label_id, "loop") # 4. End of body jumps to start
        
        return (start_label_id, end_label_id) # (Start of loop, End of loop)

    def _visit_For(self, node):
        # 1. Get the label nodes
        (start_label_id, _) = self.visit(node.start_label_node)
        (end_label_id, _) = self.visit(node.end_label_node)
        
        # 2. Create the 'for' node (acts as condition)
        cond_id = self.add_node(f"For {node.target} in {node.iter_obj}", shape="hexagon", fillcolor="lightyellow")
        
        # 3. Visit the body
        (body_start, body_end) = self.visit(node.body_block)

        # 4. Link the flow
        self.add_edge(start_label_id, cond_id) # 1. Enter loop
        self.add_edge(cond_id, body_start, "Loop Body") # 2. Enter body
        self.add_edge(cond_id, end_label_id, "Done") # 3. When done, jump to end
        self.add_edge(body_end, start_label_id, "loop") # 4. End of body jumps to start
        
        return (start_label_id, end_label_id)

    def _visit_FunctionDef(self, node):
        """Draws a function as a subgraph cluster."""
        cluster_name = f"cluster_{node.name}"
        
        with self.dot.subgraph(name=cluster_name) as c:
            c.attr(label=f"def {node.name}({node.args_text})", style="filled", color="lightgrey")
            
            start_id = self.add_node(f"Start: {node.name}", shape="Mdiamond")
            
            (body_start, body_end) = self.visit(node.body_block)
            if body_start:
                self.add_edge(start_id, body_start)

        return (start_id, start_id) # Return the function's entry point


# --- Section 5: Streamlit Application ---

def main():
    st.set_page_config(layout="wide")
    st.title("🐍 Python CFG Label Visualizer")
    st.info("Now updated to show labels as distinct nodes in the Control Flow Graph (CFG).")

    uploaded_file = st.file_uploader("Choose a Python (.py) file", type="py")

    if uploaded_file is not None:
        code_string = uploaded_file.read().decode("utf-8")
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.subheader("Uploaded Code")
            st.code(code_string, language="python")

        with col2:
            st.subheader("Labeled Control Flow Graph")
            try:
                # --- The Full Pipeline ---
                
                # 1. Parse string into Python's AST
                python_ast = ast.parse(code_string)
                
                # 2. Convert Python's AST into your custom AST
                converter = ASTConverter()
                my_ast = converter.visit(python_ast)
                
                # 3. Apply your label visitor (this mutates the tree)
                label_generator = LabelGenerator()
                label_visitor = ASTLabelVisitor(label_generator)
                label_visitor.visit(my_ast)
                
                # 4. Generate the Graphviz graph
                graph_visitor = CFGVisualizer()
                graph_visitor.visit(my_ast)
                
                # 5. Render the graph
                st.graphviz_chart(graph_visitor.dot)
                
                with st.expander("Show Graphviz DOT string"):
                    st.code(graph_visitor.dot.source, language="dot")

            except Exception as e:
                st.error(f"An error occurred during parsing or labeling:")
                st.exception(e)

if __name__ == "__main__":
    main()