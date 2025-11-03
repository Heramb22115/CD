import inspect

class LabelGenerator:
    """Generates unique, sequential labels (L0, L1, L2, ...)."""
    def __init__(self, prefix="L"):
        self.counter = 0
        self.prefix = prefix

    def get_new_label(self):
        """Generates and returns a new unique label."""
        label = f"{self.prefix}{self.counter}"
        self.counter += 1
        return label

class Node:
    """Base class for all AST nodes."""
    pass

class StatementList(Node):
    """Represents a sequence of statements."""
    def __init__(self, statements):
        self.statements = statements

class Assignment(Node):
    """Represents a simple assignment, e.g., 'x = 1'."""
    def __init__(self, variable, expression):
        self.variable = variable
        self.expression = expression

class Condition(Node):
    """Represents a condition, e.g., 'a < b'."""
    def __init__(self, text):
        self.text = text

class IfElse(Node):
    """Represents an if-else statement."""
    def __init__(self, condition, then_block, else_block):
        self.condition = condition
        self.then_block = then_block
        self.else_block = else_block
        
        self.false_label = None 
        self.end_label = None   

class While(Node):
    """Represents a while loop."""
    def __init__(self, condition, body_block):
        self.condition = condition
        self.body_block = body_block
 
        self.start_label = None 
        self.end_label = None    


class ASTLabelVisitor:
    """
    This algorithm traverses the AST (visits each node) and attaches 
    the necessary control-flow labels to conditional and loop nodes.
    
    This is an implementation of the "Visitor" design pattern.
    """
    def __init__(self, label_generator):
        self.label_gen = label_generator

    def visit(self, node):
        """
        Public "visit" method that dispatches to the correct
        private _visit_* method based on the node's class.
        """
        method_name = f"_visit_{node.__class__.__name__}"
        visitor_method = getattr(self, method_name, self._visit_default)
        return visitor_method(node)

    def _visit_default(self, node):
        """Default visitor for nodes we don't specially care about."""
       
        pass

    def _visit_StatementList(self, node):
        """Visit each statement in the list."""
        for statement in node.statements:
            self.visit(statement)

    def _visit_IfElse(self, node):
        """
        This is the core logic for "labeling" an if-else node.
        """
       
        node.false_label = self.label_gen.get_new_label()
        node.end_label = self.label_gen.get_new_label()
        self.visit(node.condition)
        self.visit(node.then_block)
        if node.else_block:
            self.visit(node.else_block)

    def _visit_While(self, node):
        """
        This is the core logic for "labeling" a while node.
        """

        node.start_label = self.label_gen.get_new_label()
        node.end_label = self.label_gen.get_new_label()

        self.visit(node.condition)
        self.visit(node.body_block)


def print_labeled_tree(node, indent=0):
    """Helper function to print the tree and show its new labels."""
    prefix = "  " * indent
    
    if isinstance(node, IfElse):
        print(f"{prefix}IfElse (FALSE -> {node.false_label}, END -> {node.end_label})")
        print(f"{prefix}  Condition:")
        print_labeled_tree(node.condition, indent + 2)
        print(f"{prefix}  Then Block:")
        print_labeled_tree(node.then_block, indent + 2)
        print(f"{prefix}  Else Block:")
        print_labeled_tree(node.else_block, indent + 2)
        
    elif isinstance(node, While):
        print(f"{prefix}While (START -> {node.start_label}, END -> {node.end_label})")
        print(f"{prefix}  Condition:")
        print_labeled_tree(node.condition, indent + 2)
        print(f"{prefix}  Body Block:")
        print_labeled_tree(node.body_block, indent + 2)
        
    elif isinstance(node, StatementList):
        print(f"{prefix}StatementList:")
        for stmt in node.statements:
            print_labeled_tree(stmt, indent + 1)
            
    elif isinstance(node, Assignment):
        print(f"{prefix}Assignment: {node.variable} = {node.expression}")
        
    elif isinstance(node, Condition):
        print(f"{prefix}Condition: {node.text}")
        
    else:
        print(f"{prefix}{node.__class__.__name__}")


if __name__ == "__main__":

    program_ast = StatementList(statements=[
        IfElse(
            condition=Condition("a < b"),
            then_block=StatementList(statements=[
                Assignment(variable="x", expression="1"),
                While(
                    condition=Condition("y > 0"),
                    body_block=StatementList(statements=[
                        Assignment(variable="y", expression="y - 1")
                    ])
                )
            ]),
            else_block=StatementList(statements=[
                Assignment(variable="x", expression="2")
            ])
        ),
        Assignment(variable="z", expression="3")
    ])

    print("--- 1. AST Before Labeling ---")
    print_labeled_tree(program_ast)
    print("\n" + "="*50 + "\n")

    label_generator = LabelGenerator()
    label_visitor = ASTLabelVisitor(label_generator)

    label_visitor.visit(program_ast)

    print("--- 2. AST After Labeling ---")
    print_labeled_tree(program_ast)