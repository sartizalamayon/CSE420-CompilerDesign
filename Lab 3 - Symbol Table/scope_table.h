#include "symbol_info.h"
class scope_table
{
private:
    int bucket_count;                  
    int unique_id;                     
    scope_table *parent_scope = NULL;
    vector<list<symbol_info *>> table; 

    int hash_function(string name)
    {
        int sum = 0;
        for (char ch : name) {
            sum += ch;
        }
        return sum % bucket_count;
    }

public:
    scope_table(int n){
        bucket_count = n;
        table.resize(bucket_count);
    };
    scope_table(int bucket_count, int unique_id, scope_table *parent_scope)
    {
        this->bucket_count = bucket_count;
        this->unique_id = unique_id;
        this->parent_scope = parent_scope;
        table.resize(bucket_count);
    };

    scope_table *get_parent_scope()
    {
        return parent_scope;
    };

    int get_unique_id()
    {
        return unique_id;
    };

    symbol_info *lookup_in_scope(symbol_info *symbol) {
        int index = hash_function(symbol->get_name());
        for (auto &sym : table[index]) {
            if (sym->get_name() == symbol->get_name()) {
                return sym;
            }
        }
        return nullptr;
    }

    bool insert_in_scope(symbol_info *symbol) {
        int index = hash_function(symbol->get_name());
        for (auto &sym : table[index]) {
            if (sym->get_name() == symbol->get_name()) {
                return false;
            }
        }
        table[index].push_back(symbol);
        return true;
    }

    bool delete_from_scope(symbol_info *symbol) {
        int index = hash_function(symbol->get_name());
        for (auto it = table[index].begin(); it != table[index].end(); ++it) {
            if ((*it)->get_name() == symbol->get_name()) {
                delete *it;
                table[index].erase(it);
                return true;
            }
        }
        return false;
    }

    void print_scope_table(ofstream &outlog) {
    for (int i = 0; i < bucket_count; i++) {
        if (!table[i].empty()) {
            outlog << i << " --> "<<endl;
            for (auto& entry : table[i]) {
                outlog << "< " + entry->get_name() + " : ID > "<<endl;
                
                if (entry->get_type() == "Array") {
                    outlog << "Array\nType: " + entry->get_data_type() + "\nSize: " + to_string(entry->get_array_size()) << endl;
                } else if (entry->get_type() == "Function") {
                    outlog << "Function Definition\nReturn Type: " + entry->get_data_type() << endl;
                    outlog << "Number of Parameters: " + to_string(entry->get_no_of_parameters()) << endl;
                    outlog << "Parameter Details: ";
                    for (int i = 0; i < entry->get_no_of_parameters(); i++) {
                        outlog << entry->get_param_type()[i] << " ";
                    }
                    outlog << endl;
                } else {
                    outlog << "Variable\nType: " + entry->get_data_type() << endl;
                }
            }
            outlog << endl;
        }
    }
    }


    ~scope_table() {
        // Destructor to clean up memory
        for (auto &bucket : table) {
            for (auto &symbol : bucket) {
                delete symbol;
            }
        }
    }
};

