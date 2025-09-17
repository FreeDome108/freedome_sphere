#include "TestProject.h"

ATestProject::ATestProject()
{
	PrimaryActorTick.bCanEverTick = true;
}

void ATestProject::BeginPlay()
{
	Super::BeginPlay();
	
	// Инициализация массива
	MyArray.Add(1);
	MyArray.Add(2);
	MyArray.Add(3);
}

void ATestProject::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);
	
	// Неэффективный цикл
	for (int i = 0; i < MyArray.size(); i++)
	{
		UE_LOG(LogTemp, Warning, TEXT("Value: %d"), MyArray[i]);
	}
	
	// Неэффективная конкатенация строк
	FString String1 = TEXT("Hello");
	FString String2 = TEXT("World");
	FString String3 = TEXT("!");
	ResultString = String1 + String2 + String3;
	
	// Вызов неэффективных методов
	InefficientMethod();
	MemoryLeakMethod();
}

void ATestProject::InefficientMethod()
{
	// Неэффективный цикл с size()
	for (int i = 0; i < MyArray.size(); i++)
	{
		// Обработка элемента
		int Value = MyArray[i];
		Value = Value * 2;
	}
	
	// Отсутствие const
	int TempValue = 42;
	FString TempString = TEXT("Temp");
}

void ATestProject::MemoryLeakMethod()
{
	// Потенциальная утечка памяти
	int* RawPointer = new int(100);
	
	// Использование указателя без освобождения
	UE_LOG(LogTemp, Warning, TEXT("Value: %d"), *RawPointer);
	
	// Забыли delete RawPointer;
}
