import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.state});

  final AppState state;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime? _chartStartDate;
  DateTime? _chartEndDate;

  @override
  void initState() {
    super.initState();
    _setChartDefaults();
  }

  void _setChartDefaults() {
    final now = DateTime.now();
    _chartStartDate = DateTime(now.year, now.month - 1, 1);
    _chartEndDate = now;
  }

  @override
  Widget build(BuildContext context) {
    final expenseRecords = widget.state.data.expenseRecords;

    // Ordina le spese dalla più recente alla più vecchia (più vicine sopra, più lontane sotto)
    final sortedExpenses = List<ExpenseRecord>.from(expenseRecords)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Spese'),
        actions: [
          IconButton(
            tooltip: 'Gestisci Budget',
            onPressed: () => _showBudgetManagement(context),
            icon: const Icon(Icons.account_balance_wallet_outlined),
          ),
          IconButton(
            tooltip: 'Aggiungi spesa',
            onPressed: () => _showAddExpenseDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: expenseRecords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Nessuna spesa registrata',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showAddExpenseDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Aggiungi prima spesa'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Riepilogo totale
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8BA888),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Totale Spese',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '€ ${_calculateTotal(sortedExpenses).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${sortedExpenses.length} spese registrate',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Sezione Budget Mensile
                _buildBudgetSection(context),

                // Lista spese
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sortedExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = sortedExpenses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF8BA888),
                            child: Icon(
                              Icons.receipt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            '€ ${expense.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(expense.formattedDateTime),
                              if (expense.note != null &&
                                  expense.note!.isNotEmpty)
                                Text(
                                  expense.note!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteExpense(expense),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  double _calculateTotal(List<ExpenseRecord> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  void _showAddExpenseDialog(BuildContext context) {
    double amount = 0.0;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String? note;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Aggiungi Spesa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Importo spesa',
                    prefixText: '€ ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    amount = double.tryParse(value) ?? 0.0;
                  },
                ),

                const SizedBox(height: 16),

                // Selezione data
                ListTile(
                  title: const Text('Data'),
                  subtitle: Text(_formatDate(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),

                // Selezione ora
                ListTile(
                  title: const Text('Ora'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setDialogState(() => selectedTime = time);
                    }
                  },
                ),

                const SizedBox(height: 8),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Note (opzionale)',
                    hintText: 'Es. Spesa al supermercato',
                  ),
                  onChanged: (value) {
                    note = value.trim().isEmpty ? null : value.trim();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () async {
                if (amount <= 0) return;

                final dateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                final expense = ExpenseRecord(
                  amount: amount,
                  dateTime: dateTime,
                  note: note,
                );

                await widget.state.addExpense(expense);

                if (context.mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Spesa aggiunta con successo!'),
                      backgroundColor: Color(0xFF8BA888),
                    ),
                  );
                }
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _deleteExpense(ExpenseRecord expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Spesa'),
        content: Text(
            'Vuoi eliminare la spesa di €${expense.amount.toStringAsFixed(2)} del ${expense.formattedDate}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () async {
              await widget.state.deleteExpense(expense);

              if (context.mounted) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Spesa eliminata'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection(BuildContext context) {
    final now = DateTime.now();
    final currentBudget = widget.state.getMonthlyBudget(now.year, now.month);
    final currentSpending =
        widget.state.getExpensesForMonth(now.year, now.month);
    final status = widget.state.getBudgetStatus(now.year, now.month);
    final percentage =
        widget.state.getBudgetPercentageUsed(now.year, now.month);
    final remaining = widget.state.getBudgetRemaining(now.year, now.month);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      constraints:
          const BoxConstraints(maxHeight: 200), // Limita l'altezza massima
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12), // Ridotto padding da 16 a 12
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Usa lo spazio minimo necessario
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: _getBudgetStatusColor(status),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Budget Mensile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getBudgetStatusColor(status),
                        ),
                  ),
                  const Spacer(),
                  if (currentBudget != null) ...[
                    IconButton(
                      onPressed: () =>
                          _showDeleteBudgetDialog(context, currentBudget),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Elimina budget',
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                  TextButton.icon(
                    onPressed: () => _showBudgetManagement(context),
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Gestisci'),
                    style: TextButton.styleFrom(
                      foregroundColor: _getBudgetStatusColor(status),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12), // Ridotto da 16 a 12
              if (currentBudget != null) ...[
                // Barra di progresso con indicatori di colore
                Stack(
                  children: [
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                          _getBudgetStatusColor(status)),
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    // Indicatori delle soglie
                    Positioned.fill(
                      child: Row(
                        children: [
                          Expanded(
                            flex:
                                ((currentBudget.yellowThreshold) * 100).round(),
                            child: Container(),
                          ),
                          Container(
                            width: 2,
                            height: 12,
                            color: Colors.orange,
                          ),
                          Expanded(
                            flex: ((currentBudget.redThreshold -
                                        currentBudget.yellowThreshold) *
                                    100)
                                .round(),
                            child: Container(),
                          ),
                          Container(
                            width: 2,
                            height: 12,
                            color: Colors.red,
                          ),
                          Expanded(
                            flex: ((1.0 - currentBudget.redThreshold) * 100)
                                .round(),
                            child: Container(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Ridotto da 16 a 10
                // Dettagli budget
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Speso',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        Text(
                          '€${currentSpending.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Budget',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        Text(
                          '€${currentBudget.amount.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rimanente',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        Text(
                          '€${remaining.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    remaining > 0 ? Colors.green : Colors.red,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Ridotto da 12 a 8
                // Stato del budget
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4), // Ridotto padding
                      decoration: BoxDecoration(
                        color: _getBudgetStatusColor(status)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _getBudgetStatusColor(status), width: 1),
                      ),
                      child: Text(
                        _getBudgetStatusText(status),
                        style: TextStyle(
                          color: _getBudgetStatusColor(status),
                          fontWeight: FontWeight.bold,
                          fontSize: 10, // Ridotto da 12 a 10
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(percentage * 100).toStringAsFixed(1)}% utilizzato',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ] else ...[
                // Nessun budget impostato
                Container(
                  padding: const EdgeInsets.all(12), // Ridotto da 16 a 12
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nessun budget impostato per questo mese. Tocca "Gestisci" per aggiungerne uno.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getBudgetStatusColor(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.verde:
        return Colors.green;
      case BudgetStatus.giallo:
        return Colors.orange;
      case BudgetStatus.rosso:
        return Colors.red;
    }
  }

  String _getBudgetStatusText(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.verde:
        return 'SOTTO CONTROLLO';
      case BudgetStatus.giallo:
        return 'ATTENZIONE';
      case BudgetStatus.rosso:
        return 'SUPERATO';
    }
  }

  void _showBudgetManagement(BuildContext context) {
    final now = DateTime.now();
    int selectedYear = now.year;
    int selectedMonth = now.month;
    final amountController = TextEditingController();
    final yellowThresholdController = TextEditingController(text: '0.8');
    final redThresholdController = TextEditingController(text: '0.95');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Gestisci Budget Mensile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selettore anno
                DropdownButtonFormField<int>(
                  initialValue: selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Anno',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(5, (index) => now.year + index)
                      .map((year) => DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedYear = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Selettore mese
                DropdownButtonFormField<int>(
                  initialValue: selectedMonth,
                  decoration: const InputDecoration(
                    labelText: 'Mese',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(12, (index) => index + 1)
                      .map((month) => DropdownMenuItem(
                            value: month,
                            child: Text(_getMonthName(month)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedMonth = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Importo budget
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Importo Budget (€)',
                    border: OutlineInputBorder(),
                    prefixText: '€ ',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                // Soglia gialla
                TextFormField(
                  controller: yellowThresholdController,
                  decoration: const InputDecoration(
                    labelText: 'Soglia Gialla (0.0 - 1.0)',
                    border: OutlineInputBorder(),
                    helperText:
                        'Percentuale per passare a giallo (es. 0.8 = 80%)',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                // Soglia rossa
                TextFormField(
                  controller: redThresholdController,
                  decoration: const InputDecoration(
                    labelText: 'Soglia Rossa (0.0 - 1.0)',
                    border: OutlineInputBorder(),
                    helperText:
                        'Percentuale per passare a rosso (es. 0.95 = 95%)',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                final yellowThreshold =
                    double.tryParse(yellowThresholdController.text) ?? 0.8;
                final redThreshold =
                    double.tryParse(redThresholdController.text) ?? 0.95;

                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Inserisci un importo valido')),
                  );
                  return;
                }

                if (yellowThreshold >= redThreshold) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'La soglia gialla deve essere inferiore a quella rossa')),
                  );
                  return;
                }

                final budget = MonthlyBudget(
                  year: selectedYear,
                  month: selectedMonth,
                  amount: amount,
                  yellowThreshold: yellowThreshold,
                  redThreshold: redThreshold,
                );

                widget.state.setMonthlyBudget(budget);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Budget salvato con successo!'),
                    backgroundColor: Color(0xFF8BA888),
                  ),
                );
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Gennaio',
      'Febbraio',
      'Marzo',
      'Aprile',
      'Maggio',
      'Giugno',
      'Luglio',
      'Agosto',
      'Settembre',
      'Ottobre',
      'Novembre',
      'Dicembre'
    ];
    return months[month - 1];
  }

  void _showDeleteBudgetDialog(BuildContext context, MonthlyBudget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Budget'),
        content: Text(
          'Sei sicuro di voler eliminare il budget di ${budget.monthLabel} ${budget.year}?\n\n'
          'Importo: €${budget.amount.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              await widget.state.deleteMonthlyBudget(budget.year, budget.month);

              if (context.mounted) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Budget eliminato con successo'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectChartStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _chartStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _chartEndDate ?? DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _chartStartDate = date;
      });
    }
  }

  Future<void> _selectChartEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _chartEndDate ?? DateTime.now(),
      firstDate: _chartStartDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _chartEndDate = date;
      });
    }
  }

  void _resetChartFilters() {
    setState(() {
      _setChartDefaults();
    });
  }

  void _setLastMonthChart() {
    final now = DateTime.now();
    setState(() {
      _chartStartDate = DateTime(now.year, now.month - 1, 1);
      _chartEndDate = DateTime(
          now.year, now.month - 1, DateTime(now.year, now.month, 0).day);
    });
  }

  void _setQuickDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _chartStartDate = today;
      _chartEndDate = now;
    });
  }

  void _setLastWeekChart() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    setState(() {
      _chartStartDate = weekAgo;
      _chartEndDate = now;
    });
  }
}
