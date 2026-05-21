"""Public API endpoints for React frontend (whitelisted)."""
import frappe
from frappe import _


@frappe.whitelist(allow_guest=True)
def ping():
    """Health check for frontend and load balancers."""
    return {
        "status": "ok",
        "app": "lab_core",
        "message": "LabProject API is running",
    }


@frappe.whitelist()
def list_lab_items():
    """List all Lab Sample Items."""
    items = frappe.get_all(
        "Lab Sample Item",
        fields=["name", "item_name", "description", "status", "modified"],
        order_by="modified desc",
    )
    return items


@frappe.whitelist()
def get_lab_item(name: str):
    """Get a single Lab Sample Item."""
    if not frappe.db.exists("Lab Sample Item", name):
        frappe.throw(_("Item not found"), frappe.DoesNotExistError)
    doc = frappe.get_doc("Lab Sample Item", name)
    return doc.as_dict()


@frappe.whitelist()
def create_lab_item(item_name: str, description: str = "", status: str = "Draft"):
    """Create a Lab Sample Item."""
    doc = frappe.get_doc(
        {
            "doctype": "Lab Sample Item",
            "item_name": item_name,
            "description": description,
            "status": status or "Draft",
        }
    )
    doc.insert()
    frappe.db.commit()
    return doc.as_dict()


@frappe.whitelist()
def update_lab_item(name: str, item_name: str = None, description: str = None, status: str = None):
    """Update a Lab Sample Item."""
    doc = frappe.get_doc("Lab Sample Item", name)
    if item_name is not None:
        doc.item_name = item_name
    if description is not None:
        doc.description = description
    if status is not None:
        doc.status = status
    doc.save()
    frappe.db.commit()
    return doc.as_dict()


@frappe.whitelist()
def delete_lab_item(name: str):
    """Delete a Lab Sample Item."""
    frappe.delete_doc("Lab Sample Item", name)
    frappe.db.commit()
    return {"deleted": name}
