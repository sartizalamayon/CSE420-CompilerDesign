#include "scope_table.h"

class symbol_table
{
private:
    scope_table *current_scope;
    int bucket_count;
    int current_scope_id;

public:
    symbol_table(int bucket_count)
    {
        this->bucket_count = bucket_count;
        current_scope = new scope_table(bucket_count, 1, NULL);
        current_scope_id = 1;
    };
    ~symbol_table()
    {
        while (current_scope != NULL) {
            scope_table* temp = current_scope;
            current_scope = current_scope->get_parent_scope();
            delete temp;
        }
    };

   
    
    void enter_scope() {
        current_scope_id++;
        scope_table *new_scope = new scope_table(bucket_count, current_scope_id, current_scope);
        current_scope = new_scope;       
    }

    void exit_scope() {
        if (current_scope == NULL) {
            return;
        }
        if (current_scope) {
            scope_table *temp = current_scope;
            current_scope = current_scope->get_parent_scope();
        }
    }

    bool insert(symbol_info* symbol)
    {
        if (current_scope == NULL) {
            return false;
        }
        return current_scope->insert_in_scope(symbol);
    };

    symbol_info *lookup(symbol_info *symbol) {
        scope_table* temp = current_scope;
        while (temp != NULL) {
            symbol_info* found_symbol = temp->lookup_in_scope(symbol);
            if (found_symbol != NULL) {
                return found_symbol;  
            }
            temp = temp->get_parent_scope();  
        }
        return NULL;
    }

    void print_current_scope(ofstream &outlog) {
        if (current_scope != NULL) {
            current_scope->print_scope_table(outlog);
        }
    }

    void print_all_scopes(ofstream &outlog) {
        outlog << "################################" << endl;
        scope_table *temp_scope = current_scope;
        while (temp_scope != nullptr) {
            temp_scope->print_scope_table(outlog);
            temp_scope = temp_scope->get_parent_scope();
        }
        outlog << "################################" << endl;
    }

    
    bool remove(symbol_info *symbol) {
        return current_scope->delete_from_scope(symbol);
    }

    int get_current_scope_id() {
        return current_scope->get_unique_id();
    }
};